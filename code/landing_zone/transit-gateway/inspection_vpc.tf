

locals {
  inspection_vpc_azs = slice(data.aws_availability_zones.available.names, 0, 4)
  firewall_name      = "network-firewall"
  tags = {
    Name = "network-firewall"
  }
}

################################################################################
# inspection vpc Module
################################################################################

module "inspection_vpc" {
  source          = "../../../terraform_module/terraform-aws-vpc"
  name            = "inspection"
  cidr            = var.inspection_cidr
  private_subnets = var.inspection_private_subnets
  azs             = local.inspection_vpc_azs

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  private_dedicated_network_acl = true

  private_inbound_acl_rules  = var.private_inbound_acl_rules
  private_outbound_acl_rules = var.private_outbound_acl_rules


  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

}

################################################################################
# network firewall Module
################################################################################

# module "network_firewall" {
#   source = "../../../terraform_module/terraform-aws-network-firewall"

#   # Firewall
#   name = local.firewall_name

#   # Only for testing
#   delete_protection                 = false
#   firewall_policy_change_protection = false
#   subnet_change_protection          = false

#   vpc_id = module.inspection_vpc.vpc_id
#   subnet_mapping = { for i in range(0, length(local.inspection_vpc_azs)) :
#     "subnet-${i}" => {
#       subnet_id       = element(module.inspection_vpc.private_subnets, i)
#       ip_address_type = "IPV4"
#     }
#   }

#   tags = local.tags
# }