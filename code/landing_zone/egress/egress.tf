# create vpc with inbound traffic only with 2 public and 2 private subnets

provider "aws" {
  region = var.default_region
}

data "aws_availability_zones" "available" {}

locals {
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
  name = "egress"

}
module "egress_vpc" {
  source          = "../../../terraform_module/terraform-aws-vpc"
  name            = local.name
  cidr            = var.egress_cidr
  public_subnets  = var.egress_public_subnets
  private_subnets = var.egress_private_subnets

  public_dedicated_network_acl  = true
  private_dedicated_network_acl = true
  public_inbound_acl_rules      = var.public_inbound_acl_rules
  public_outbound_acl_rules     = var.public_outbound_acl_rules

  private_inbound_acl_rules  = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

}