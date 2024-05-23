output "waf_policy_id" {
  description = "Waf Policy ID"
  value       = module.mod_waf_policy.waf_policy_id
}

output "waf_policy_loop_id" {
  description = "Waf Policy ID"
#   value       = module.mod_waf_policy_loop.waf_policy_id
value = [ for waf_policy_id in module.mod_waf_policy_loop : waf_policy_id.waf_policy_id ]
}
