data "aws_region" "current" {}

################################
# VPC
################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc" }
}

################################
# Subnets
################################
resource "aws_subnet" "public" {
  for_each                  = var.public_subnets
  vpc_id                    = aws_vpc.this.id
  availability_zone         = each.key
  cidr_block                = each.value
  map_public_ip_on_launch   = true
  tags = { Name = "${var.name}-pub-${each.key}", Tier = "public" }
}

resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = { Name = "${var.name}-prv-${each.key}", Tier = "private" }
}

resource "aws_subnet" "firewall" {
  for_each          = var.firewall_subnets
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = { Name = "${var.name}-nfw-${each.key}", Role = "nfw-endpoint" }
}

################################
# IGW + NAT (per AZ)
################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"
  tags     = { Name = "${var.name}-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  subnet_id     = each.value.id
  allocation_id = aws_eip.nat[each.key].id
  tags          = { Name = "${var.name}-nat-${each.key}" }
  depends_on    = [aws_internet_gateway.igw]
}

################################
# Route tables - Public → IGW
################################
resource "aws_route_table" "public" {
  for_each = aws_subnet.public
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-rtb-pub-${each.key}" }
}
resource "aws_route" "public_default" {
  for_each               = aws_route_table.public
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}

################################
# AWS Network Firewall (baseline allow-all)
################################
resource "aws_networkfirewall_rule_group" "stateful_allow_all" {
  capacity = 100
  name     = "${var.name}-stateful-allow-all"
  type     = "STATEFUL"
  rule_group = jsonencode({
    rulesSource = { rulesString = "pass any any -> any any (sid:1;)" }
  })
}

resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.name}-nfw-policy"
  firewall_policy = jsonencode({
    statelessDefaultActions = ["aws:forward_to_sfe"],
    statelessFragmentDefaultActions = ["aws:forward_to_sfe"],
    statefulRuleGroupReferences = [
      { resourceArn = aws_networkfirewall_rule_group.stateful_allow_all.arn }
    ]
  })
}

resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.name}-nfw"
  vpc_id              = aws_vpc.this.id
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn

  dynamic "subnet_mapping" {
    for_each = [for _, s in aws_subnet.firewall : s.id]
    content { subnet_id = subnet_mapping.value }
  }

  tags = { Name = "${var.name}-nfw" }
}

data "aws_networkfirewall_firewall" "read" {
  firewall_arn = aws_networkfirewall_firewall.this.arn
}

locals {
  nfw_endpoint_ids_by_az = {
    for s in data.aws_networkfirewall_firewall.read.firewall_status[0].sync_states :
    s.availability_zone => s.attachment[0].endpoint_id
  }
}

################################
# Route tables - Firewall → NAT → IGW
################################
resource "aws_route_table" "firewall" {
  for_each = aws_subnet.firewall
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-rtb-nfw-${each.key}" }
}
resource "aws_route" "firewall_to_nat" {
  for_each               = aws_route_table.firewall
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}
resource "aws_route_table_association" "firewall_assoc" {
  for_each       = aws_subnet.firewall
  subnet_id      = each.value.id
  route_table_id = aws_route_table.firewall[each.key].id
}

################################
# TGW (one per VPC) + attachment
################################
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "${var.name} tgw"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = { Name = "${var.name}-tgw" }
}

# Create dedicated TGW attach subnets only when NOT reusing private
resource "aws_subnet" "tgw_attach" {
  for_each = var.reuse_private_for_tgw ? {} : var.tgw_attach_subnets
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = { Name = "${var.name}-tgw-${each.key}", Role = "tgw-attach" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attach" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = var.reuse_private_for_tgw
                        ? [for _, s in aws_subnet.private : s.id]
                        : [for _, s in aws_subnet.tgw_attach : s.id]
  tags = { Name = "${var.name}-tgw-attach" }
}

################################
# Route tables - Private
#  - 0.0.0.0/0 → NFW endpoint (same AZ)
#  - corp_cidrs → TGW
################################
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-rtb-prv-${each.key}" }
}
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_default_to_nfw" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.nfw_endpoint_ids_by_az[each.key]
}

# One resource per (AZ, CIDR) for corp routing via TGW
locals {
  az_cidr_pairs = flatten([
    for az, rt in aws_route_table.private : [
      for cidr in var.corp_cidrs_via_tgw : {
        az   = az
        rtid = rt.id
        cidr = cidr
      }
    ]
  ])
}

resource "aws_route" "private_corp_to_tgw" {
  for_each               = { for i, p in local.az_cidr_pairs : i => p }
  route_table_id         = each.value.rtid
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
