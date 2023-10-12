
locals {
  name = "egress"

}

module "egress_vpc" {
  source          = "../../../terraform_module/terraform-aws-vpc"
  name            = local.name
  cidr            = var.egress_cidr
  private_subnets = var.egress_private_subnets

  private_dedicated_network_acl = true
  manage_default_network_acl    = false
  private_inbound_acl_rules     = var.private_inbound_acl_rules
  private_outbound_acl_rules    = var.private_outbound_acl_rules


  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

}