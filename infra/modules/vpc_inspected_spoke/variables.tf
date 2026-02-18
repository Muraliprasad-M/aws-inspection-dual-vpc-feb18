variable "name"                  { type = string }
variable "vpc_cidr"              { type = string }
variable "azs"                   { type = list(string) }

variable "public_subnets"        { type = map(string) }
variable "private_subnets"       { type = map(string) }
variable "firewall_subnets"      { type = map(string) }
variable "tgw_attach_subnets"    { type = map(string) }
variable "reuse_private_for_tgw" { type = bool, default = false }

variable "corp_cidrs_via_tgw"    { type = list(string), default = [] }
