module "it" {
  source = "./modules/vpc_inspected_spoke"

  name                    = "it"
  vpc_cidr                = var.it_vpc_cidr
  azs                     = var.azs

  public_subnets          = var.it_public_subnets
  private_subnets         = var.it_private_subnets
  firewall_subnets        = var.it_firewall_subnets
  tgw_attach_subnets      = var.it_tgw_attach_subnets
  reuse_private_for_tgw   = var.it_reuse_private_for_tgw

  corp_cidrs_via_tgw      = var.it_corp_cidrs
}

module "ot" {
  source = "./modules/vpc_inspected_spoke"

  name                    = "ot"
  vpc_cidr                = var.ot_vpc_cidr
  azs                     = var.azs

  public_subnets          = var.ot_public_subnets
  private_subnets         = var.ot_private_subnets
  firewall_subnets        = var.ot_firewall_subnets
  tgw_attach_subnets      = var.ot_tgw_attach_subnets
  reuse_private_for_tgw   = var.ot_reuse_private_for_tgw

  corp_cidrs_via_tgw      = var.ot_corp_cidrs
}
