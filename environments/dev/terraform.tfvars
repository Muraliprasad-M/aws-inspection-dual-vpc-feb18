aws_region = "eu-west-2"
azs        = ["eu-west-2a","eu-west-2b","eu-west-2c"]

# ----- IT -----
it_vpc_cidr = "10.232.0.0/22"

it_public_subnets = {
  "eu-west-2a" = "10.232.0.0/26"
  "eu-west-2b" = "10.232.0.64/26"
  "eu-west-2c" = "10.232.0.128/26"
}

it_private_subnets = {
  "eu-west-2a" = "10.232.1.0/24"
  "eu-west-2b" = "10.232.2.0/24"
  "eu-west-2c" = "10.232.3.0/24"
}

it_firewall_subnets = {
  "eu-west-2a" = "10.232.0.192/28"
  "eu-west-2b" = "10.232.0.208/28"
  "eu-west-2c" = "10.232.0.224/28"
}

it_tgw_attach_subnets = {
  "eu-west-2a" = "10.232.1.240/28"
  "eu-west-2b" = "10.232.2.240/28"
  "eu-west-2c" = "10.232.3.240/28"
}

it_corp_cidrs = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]
it_reuse_private_for_tgw = false

# ----- OT -----
ot_vpc_cidr = "10.232.128.0/22"

ot_public_subnets = {
  "eu-west-2a" = "10.232.128.0/26"
  "eu-west-2b" = "10.232.128.64/26"
  "eu-west-2c" = "10.232.128.128/26"
}

ot_private_subnets = {
  "eu-west-2a" = "10.232.129.0/24"
  "eu-west-2b" = "10.232.130.0/24"
  "eu-west-2c" = "10.232.131.0/24"
}

ot_firewall_subnets = {
  "eu-west-2a" = "10.232.128.192/28"
  "eu-west-2b" = "10.232.128.208/28"
  "eu-west-2c" = "10.232.128.224/28"
}

ot_tgw_attach_subnets = {
  "eu-west-2a" = "10.232.129.240/28"
  "eu-west-2b" = "10.232.130.240/28"
  "eu-west-2c" = "10.232.131.240/28"
}

ot_corp_cidrs = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]
ot_reuse_private_for_tgw = false

default_tags = {
  Owner       = "Platform"
  ManagedBy   = "Terraform"
  Environment = "dev"
}
