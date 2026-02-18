output "it_vpc_id"       { value = module.it.vpc_id }
output "it_tgw_id"       { value = module.it.tgw_id }
output "it_firewall_arn" { value = module.it.firewall_arn }

output "ot_vpc_id"       { value = module.ot.vpc_id }
output "ot_tgw_id"       { value = module.ot.tgw_id }
output "ot_firewall_arn" { value = module.ot.firewall_arn }
