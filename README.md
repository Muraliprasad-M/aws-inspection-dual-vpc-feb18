# Dual VPC with Per-VPC TGW and AWS Network Firewall (eu-west-2)

This repo deploys **two VPCs** (IT & OT), each with:

- 3 public subnets (one per AZ) with IGW & NAT (per AZ)
- 3 private subnets (one per AZ) routed to **AWS Network Firewall** for internet egress
- 3 firewall subnets (one per AZ) for **AWS Network Firewall** endpoints
- A **dedicated Transit Gateway** (one per VPC) and VPC attachment
- Private route tables contain:
  - `0.0.0.0/0` → NFW endpoint (same AZ)
  - Corporate CIDRs (from `*_corp_cidrs`) → TGW

## Deploy

1. Create S3 bucket + DynamoDB table for Terraform state (update `environments/dev/state.hcl`).
2. Create an Azure DevOps **OIDC** AWS service connection named `aws-oidc-euw2` targeting the account/role you will use.
3. Commit, run the pipeline at `pipelines/azure-pipelines.yml` and approve the **Apply** stage.

## Inputs
Edit `environments/dev/terraform.tfvars` to adjust CIDRs and corporate routes.

## Notes
- AWS Network Firewall requires **separate firewall subnets** per AZ.
- If you want to avoid dedicated TGW /28s, set `*_reuse_private_for_tgw = true` to use private subnets for TGW attachment.
- The default firewall policy is **allow-all** to let traffic flow; replace with your own rule groups.
