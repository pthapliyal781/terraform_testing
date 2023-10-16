
module "egress_vpc" {
  source          = "../../../terraform_module/terraform-aws-vpc"
  name            = "egress"
  cidr            = var.egress_cidr
  azs             = local.azs
  private_subnets = var.egress_private_subnets
  public_subnets  = var.egress_public_subnets


  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

}