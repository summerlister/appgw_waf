#############################################################################
# IDENTITY AND KEYVAULT ACCESS
#############################################################################

resource "azurerm_user_assigned_identity" "managedidentity" {
  resource_group_name = "eastHubRg"
  location            = "eastus"
  name                = "appgw-api"
}

resource "azurerm_role_assignment" "akv_access" {
  scope                = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.KeyVault/vaults/summerlisterKV"
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.managedidentity.principal_id
}


#############################################################################
# MODULES
#############################################################################

module "application-gateway" {
  source = "./../../appgw"
  #   version = "x.x.x"

  # By default, this module will not create a resource group and expect to provide 
  # a existing RG name to use an existing resource group. Location will be same as existing RG. 
  # set the argument to `create_resource_group = true` to create new resrouce.
  resource_group_name  = "eastHubRg"
  location             = "eastus"
  virtual_network_name = "eastHubVnet"
  subnet_name          = "appGWSubnet"
  app_gateway_name     = "testgateway"
  firewall_policy_id   = module.waf_policy_global.waf_policy_id


  # SKU requires `name`, `tier` to use for this Application Gateway
  # `Capacity` property is optional if `autoscale_configuration` is set
  sku = {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 5
  }


  # TLS termination (previously known as Secure Sockets Layer (SSL) Offloading)
  # The certificate on the listener requires the entire certificate chain (PFX certificate) to be uploaded to establish the chain of trust.
  # Authentication and trusted root certificate setup are not required for trusted Azure services such as Azure App Service.
  ssl_certificates = [{
    name = "appgw-testgateway-eastus-ssl01"
    # data     = "./keyBag.pfx"
    # password = "P@$$w0rd123"
    key_vault_secret_id = "https://xxx.vault.azure.net/secrets/xxx/xxx"
  }]

  # By default, an application gateway monitors the health of all resources in its backend pool and automatically removes unhealthy ones. 
  # It then monitors unhealthy instances and adds them back to the healthy backend pool when they become available and respond to health probes.
  # must allow incoming Internet traffic on TCP ports 65503-65534 for the Application Gateway v1 SKU, and TCP ports 65200-65535 
  # for the v2 SKU with the destination subnet as Any and source as GatewayManager service tag. This port range is required for Azure infrastructure communication.
  # Additionally, outbound Internet connectivity can't be blocked, and inbound traffic coming from the AzureLoadBalancer tag must be allowed.
  health_probes = [
    {
      name                = "appgw-testgateway-eastus-probe1"
      host                = "127.0.0.1"
      interval            = 30
      path                = "/"
      port                = 443
      timeout             = 30
      unhealthy_threshold = 3
    }
  ]


  # An application gateway routes traffic to the backend servers using the port, protocol, and other settings
  # The port and protocol used to check traffic is encrypted between the application gateway and backend servers
  # List of backend HTTP settings can be added here.  
  # `probe_name` argument is required if you are defing health probes.
  backend_http_settings = [
    {
      name                  = "appgw-testgateway-eastus-settings-https-general"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      enable_https          = true
      request_timeout       = 30
      probe_name            = "appgw-testgateway-eastus-probe1" # Remove this if `health_probes` object is not defined.
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300

      }
    },
    {
      name                  = "appgw-testgateway-eastus-settings-http-general"
      cookie_based_affinity = "Enabled"
      path                  = "/"
      enable_https          = false
      request_timeout       = 30
    },
  ]

  # A backend pool routes request to backend servers, which serve the request.
  # Can create different backend pools for different types of requests
  backend_address_pools = [
    {
      name  = "appgw-testgateway-eastus-bapool01"
      fqdns = ["example1.com", "example2.com"]
    },
    {
      name         = "appgw-testgateway-eastus-bapool02"
      ip_addresses = ["1.2.3.4", "2.3.4.5"]
    },
    {
      name         = "appgw-testgateway-eastus-bapool03"
      ip_addresses = ["1.2.3.4"]
    }
  ]

  # List of HTTP/HTTPS listeners. SSL Certificate name is required
  # `Basic` - This type of listener listens to a single domain site, where it has a single DNS mapping to the IP address of the 
  # application gateway. This listener configuration is required when you host a single site behind an application gateway.
  # `Multi-site` - This listener configuration is required when you want to configure routing based on host name or domain name for 
  # more than one web application on the same application gateway. Each website can be directed to its own backend pool.
  # Setting `host_name` value changes Listener Type to 'Multi site`. `host_names` allows special wildcard charcters.
  http_listeners = [
    {
      name                 = "appgw-testgateway-eastus-listener-www"
      ssl_certificate_name = "appgw-testgateway-eastus-ssl01"
      host_name            = "www.summerlister.com"
      firewall_policy_id   = module.waf_policy_www.waf_policy_id
    },
    {
      name                 = "appgw-testgateway-eastus-listener-test"
      ssl_certificate_name = "appgw-testgateway-eastus-ssl01"
      host_name            = "test.summerlister.com"
    },
    {
      name                 = "appgw-testgateway-eastus-listener-dev"
      ssl_certificate_name = "appgw-testgateway-eastus-ssl01"
      host_name            = "dev.summerlister.com"
      firewall_policy_id = module.waf_policy_dev.waf_policy_id
    }
  ]

  # Request routing rule is to determine how to route traffic on the listener. 
  # The rule binds the listener, the back-end server pool, and the backend HTTP settings.
  # `Basic` - All requests on the associated listener (for example, blog.contoso.com/*) are forwarded to the associated 
  # backend pool by using the associated HTTP setting.
  # `Path-based` - This routing rule lets you route the requests on the associated listener to a specific backend pool, 
  # based on the URL in the request. 
  request_routing_rules = [
    {
      name                       = "appgw-testgateway-eastus-rr-www"
      rule_type                  = "Basic"
      http_listener_name         = "appgw-testgateway-eastus-listener-www"
      backend_address_pool_name  = "appgw-testgateway-eastus-bapool01"
      backend_http_settings_name = "appgw-testgateway-eastus-settings-https-general"
      priority                   = 2
    },
    {
      name                       = "appgw-testgateway-eastus-rr-test"
      rule_type                  = "Basic"
      http_listener_name         = "appgw-testgateway-eastus-listener-test"
      backend_address_pool_name  = "appgw-testgateway-eastus-bapool02"
      backend_http_settings_name = "appgw-testgateway-eastus-settings-https-general"
      priority                   = 3
    },
    {
      name                       = "appgw-testgateway-eastus-rr-dev"
      rule_type                  = "Basic"
      http_listener_name         = "appgw-testgateway-eastus-listener-dev"
      backend_address_pool_name  = "appgw-testgateway-eastus-bapool03"
      backend_http_settings_name = "appgw-testgateway-eastus-settings-https-general"
      priority                   = 4
    }
  ]

  # A list with a single user managed identity id to be assigned to access Keyvault
  identity_ids = ["${azurerm_user_assigned_identity.managedidentity.id}"]

  # (Optional) To enable Azure Monitoring for Azure Application Gateway
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  log_analytics_workspace_name = "xxx"

  # Adding TAG's to Azure resources
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
  depends_on = [ azurerm_role_assignment.akv_access ]
}