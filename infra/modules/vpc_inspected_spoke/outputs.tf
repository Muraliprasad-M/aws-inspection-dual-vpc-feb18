output "vpc_id"       { value = aws_vpc.this.id }
output "tgw_id"       { value = aws_ec2_transit_gateway.tgw.id }
output "firewall_arn" { value = aws_networkfirewall_firewall.this.arn }

output "public_subnet_ids"  { value = [for _, s in aws_subnet.public  : s.id] }
output "private_subnet_ids" { value = [for _, s in aws_subnet.private : s.id] }
