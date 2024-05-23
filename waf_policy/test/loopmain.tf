

###################################################
# Locals
###################################################

locals {
  waf_policy = {
    cust1 = {
      tags = {
        managed_by = "Terraform"
      }
      resource_group_name = "eastHubRg"
      location            = "eastus"
      #   policy_name         = "waf-policy1"
      policy_mode = "Detection"
      managed_rule_set_configuration = [
        {
          type    = "OWASP"
          version = "3.2"
        }
      ]

      custom_rules_configuration = [
        {
          name      = "AllowAll"
          priority  = 1
          rule_type = "MatchRule"
          action    = "Allow"

          match_conditions_configuration = [
            {
              match_variable_configuration = [
                {
                  variable_name = "RemoteAddr"
                  selector      = null
                }
              ]

              match_values = [
                "1.1.1.1"
              ]

              operator           = "IPMatch"
              negation_condition = true
              transforms         = null
            },
            {
              match_variable_configuration = [
                {
                  variable_name = "RequestUri"
                  selector      = null
                },
                {
                  variable_name = "RequestBody"
                  selector      = null
                }
              ]

              match_values = [
                "Azure",
                "Cloud"
              ]

              operator           = "Contains"
              negation_condition = true
              transforms         = null
            }
          ]
        }
      ]
    }
    cust2 = {
      tags = {
        managed_by = "Terraform"
      }
      resource_group_name = "eastHubRg"
      location            = "eastus"
      #   policy_name         = "waf-policy1"
      policy_mode = "Detection"
      managed_rule_set_configuration = [
        {
          type    = "OWASP"
          version = "3.2"
        }
      ]

      custom_rules_configuration = [
        {
          name      = "DenyAll"
          priority  = 1
          rule_type = "MatchRule"
          action    = "Block"

          match_conditions_configuration = [
            {
              match_variable_configuration = [
                {
                  variable_name = "RemoteAddr"
                  selector      = null
                }
              ]

              match_values = [
                "1.1.1.1"
              ]

              operator           = "IPMatch"
              negation_condition = true
              transforms         = null
            },
            {
              match_variable_configuration = [
                {
                  variable_name = "RequestUri"
                  selector      = null
                },
                {
                  variable_name = "RequestBody"
                  selector      = null
                }
              ]

              match_values = [
                "Azure",
                "Cloud"
              ]

              operator           = "Contains"
              negation_condition = true
              transforms         = null
            }
          ]
        }
      ]
    }
  }
}



#############################################################################
# MODULES
#############################################################################

module "mod_waf_policy_loop" {
  for_each = local.waf_policy
  source   = "./.."
  #version = "~> x.x.x"  
  #   create_resource_group = true
  resource_group_name            = each.value.resource_group_name
  location                       = each.value.location
  policy_name                    = "${each.key}-wafpolicy"
  policy_mode                    = each.value.policy_mode
  managed_rule_set_configuration = each.value.managed_rule_set_configuration
  custom_rules_configuration     = each.value.custom_rules_configuration
}