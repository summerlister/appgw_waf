<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_web_application_firewall_policy.waf_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Whether to create resource group and use it for all networking resources | `bool` | `false` | no |
| <a name="input_custom_rules_configuration"></a> [custom\_rules\_configuration](#input\_custom\_rules\_configuration) | Custom rules configuration object with following attributes:<pre>- name:                           Gets name of the resource that is unique within a policy. This name can be used to access the resource.<br>- priority:                       Describes priority of the rule. Rules with a lower value will be evaluated before rules with a higher value.<br>- rule_type:                      Describes the type of rule. Possible values are `MatchRule` and `Invalid`.<br>- action:                         Type of action. Possible values are `Allow`, `Block` and `Log`.<br>- match_conditions_configuration: One or more `match_conditions` blocks as defined below.<br>- match_variable_configuration:   One or more match_variables blocks as defined below.<br>- variable_name:                  The name of the Match Variable. Possible values are RemoteAddr, RequestMethod, QueryString, PostArgs, RequestUri, RequestHeaders, RequestBody and RequestCookies.<br>- selector:                       Describes field of the matchVariable collection<br>- match_values:                   A list of match values.<br>- operator:                       Describes operator to be matched. Possible values are IPMatch, GeoMatch, Equal, Contains, LessThan, GreaterThan, LessThanOrEqual, GreaterThanOrEqual, BeginsWith, EndsWith and Regex.<br>- negation_condition:             Describes if this is negate condition or not<br>- transforms:                     A list of transformations to do before the match is attempted. Possible values are HtmlEntityDecode, Lowercase, RemoveNulls, Trim, UrlDecode and UrlEncode.</pre> | <pre>list(object({<br>    name      = optional(string)<br>    priority  = optional(number)<br>    rule_type = optional(string)<br>    action    = optional(string)<br>    match_conditions_configuration = optional(list(object({<br>      match_variable_configuration = optional(list(object({<br>        variable_name = optional(string)<br>        selector      = optional(string, null)<br>      })))<br>      match_values       = optional(list(string))<br>      operator           = optional(string)<br>      negation_condition = optional(string, null)<br>      transforms         = optional(list(string), null)<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_custom_waf_resource_group_name"></a> [custom\_waf\_resource\_group\_name](#input\_custom\_waf\_resource\_group\_name) | The name of the custom resource group to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_exclusion_configuration"></a> [exclusion\_configuration](#input\_exclusion\_configuration) | Exclusion rules configuration object with following attributes:<pre>- match_variable:          The name of the Match Variable. Accepted values can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#match_variable<br>- selector:                Describes field of the matchVariable collection.<br>- selector_match_operator: Describes operator to be matched. Possible values: `Contains`, `EndsWith`, `Equals`, `EqualsAny`, `StartsWith`.<br>- excluded_rule_set:       One or more `excluded_rule_set` block defined below.<br>- type:                    The rule set type. The only possible value is `OWASP` . Defaults to `OWASP`.<br>- version:                 The rule set version. The only possible value is `3.2` . Defaults to `3.2`.<br>- rule_group:              One or more `rule_group` block defined below.<br>- rule_group_name:         The name of rule group for exclusion. Accepted values can be found here: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#rule_group_name<br>- excluded_rules:          One or more Rule IDs for exclusion.</pre> | <pre>list(object({<br>    match_variable          = optional(string)<br>    selector                = optional(string)<br>    selector_match_operator = optional(string)<br>    excluded_rule_set = optional(list(object({<br>      type    = optional(string, "OWASP")<br>      version = optional(string, "3.2")<br>      rule_group = optional(list(object({<br>        rule_group_name = optional(string)<br>        excluded_rules  = optional(string)<br>      })))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `""` | no |
| <a name="input_managed_rule_set_configuration"></a> [managed\_rule\_set\_configuration](#input\_managed\_rule\_set\_configuration) | Managed rule set configuration. | <pre>list(object({<br>    type    = optional(string, "OWASP")<br>    version = optional(string, "3.2")<br>    rule_group_override_configuration = optional(list(object({<br>      rule_group_name = optional(string, null)<br>      rule = optional(list(object({<br>        id      = string<br>        enabled = optional(bool)<br>        action  = optional(string)<br>      })), [])<br>    })))<br><br>  }))</pre> | `[]` | no |
| <a name="input_policy_enabled"></a> [policy\_enabled](#input\_policy\_enabled) | Describes if the policy is in `enabled` state or `disabled` state. Defaults to `true`. | `string` | `true` | no |
| <a name="input_policy_file_limit"></a> [policy\_file\_limit](#input\_policy\_file\_limit) | Policy regarding the size limit of uploaded files. Value is in MB. Accepted values are in the range `1` to `4000`. Defaults to `100`. | `number` | `100` | no |
| <a name="input_policy_max_body_size"></a> [policy\_max\_body\_size](#input\_policy\_max\_body\_size) | Policy regarding the maximum request body size. Value is in KB. Accepted values are in the range `8` to `2000`. Defaults to `128`. | `number` | `128` | no |
| <a name="input_policy_mode"></a> [policy\_mode](#input\_policy\_mode) | Describes if it is in detection mode or prevention mode at the policy level. Valid values are `Detection` and `Prevention`. Defaults to `Prevention`. | `string` | `"Prevention"` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | The name of the WAF Policy | `string` | `""` | no |
| <a name="input_policy_request_body_check_enabled"></a> [policy\_request\_body\_check\_enabled](#input\_policy\_request\_body\_check\_enabled) | Describes if the Request Body Inspection is enabled. Defaults to `true`. | `string` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | A container that holds related resources for an Azure solution | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_waf_policy_custom_name"></a> [waf\_policy\_custom\_name](#input\_waf\_policy\_custom\_name) | Custom WAF Policy name, generated if not set. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_waf_policy_id"></a> [waf\_policy\_id](#output\_waf\_policy\_id) | Waf Policy ID |
<!-- END_TF_DOCS -->