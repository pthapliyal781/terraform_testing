provider "aws" {
  region = var.default_region
}

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

}
module "vpc" {
  source           = "../../../terraform_module/terraform-aws-vpc"
  cidr             = var.cidr
  name             = var.name
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  azs              = local.azs

  manage_default_network_acl    = true
  public_dedicated_network_acl  = true
  private_dedicated_network_acl = true
  create_database_subnet_group  = true

  public_inbound_acl_rules  = var.public_inbound_acl_rules
  public_outbound_acl_rules = var.public_outbound_acl_rules

  private_inbound_acl_rules  = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules

  database_dedicated_network_acl = true
  database_inbound_acl_rules     = var.database_inbound_acl_rules
  database_outbound_acl_rules    = var.database_outbound_acl_rules

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

}