#############################################################################
# MODULES
#############################################################################

module "waf_policy_global" {
  source   = "./../../waf_policy"
  #version = "~> x.x.x"  
  #   create_resource_group = true
  resource_group_name = "eastHubRg"
  location            = "eastus"
  policy_name                    = "global"
  policy_mode                    = "Detection"
  managed_rule_set_configuration = [
        {
          # type    = "OWASP"
          # version = "3.2"
        }
      ]
  custom_rules_configuration     = [
        {
          name      = "AllowIP"
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
              negation_condition = false
              transforms         = null
            },
            # {
            #   match_variable_configuration = [
            #     {
            #       variable_name = "RequestUri"
            #       selector      = null
            #     },
            #     {
            #       variable_name = "RequestBody"
            #       selector      = null
            #     }
            #   ]

            #   match_values = [
            #     "Azure",
            #     "Cloud"
            #   ]

            #   operator           = "Contains"
            #   negation_condition = true
            #   transforms         = null
            # }
          ]
        }
      ]
}