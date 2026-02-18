variable "aws_region" { type = string, default = "eu-west-2" }
variable "azs" {
  type    = list(string)
  default = ["eu-west-2a","eu-west-2b","eu-west-2c"]
}
variable "default_tags" {
  type = map(string)
  default = { ManagedBy = "Terraform", Environment = "dev" }
}

# ====== IT inputs ======
variable "it_vpc_cidr"                 { type = string }
variable "it_public_subnets"           { type = map(string) }
variable "it_private_subnets"          { type = map(string) }
variable "it_firewall_subnets"         { type = map(string) }
variable "it_tgw_attach_subnets"       { type = map(string) }
variable "it_corp_cidrs"               { type = list(string) }
variable "it_reuse_private_for_tgw"    { type = bool, default = false }

# ====== OT inputs ======
variable "ot_vpc_cidr"                 { type = string }
variable "ot_public_subnets"           { type = map(string) }
variable "ot_private_subnets"          { type = map(string) }
variable "ot_firewall_subnets"         { type = map(string) }
variable "ot_tgw_attach_subnets"       { type = map(string) }
variable "ot_corp_cidrs"               { type = list(string) }
variable "ot_reuse_private_for_tgw"    { type = bool, default = false }
