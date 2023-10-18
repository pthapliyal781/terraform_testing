
locals {
  name = "ingress_vpc"
}

module "ingress_vpc" {
  source          = "../../../terraform_module/terraform-aws-vpc"
  name            = "ingress"
  cidr            = var.ingress_cidr
  private_subnets = var.ingress_private_subnets
  public_subnets  = var.ingress_public_subnets
  azs             = local.azs

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  public_dedicated_network_acl = true
  public_inbound_acl_rules     = var.ingress_public_inbound_acl_rules
  public_outbound_acl_rules    = var.ingress_public_outbound_acl_rules

  private_dedicated_network_acl = true
  private_inbound_acl_rules     = var.ingress_private_inbound_acl_rules
  private_outbound_acl_rules    = var.ingress_private_outbound_acl_rules


  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

}

module "ingress_alb" {
  source                = "../../../terraform_module/terraform-aws-alb"
  name                  = "ingress-alb"
  load_balancer_type    = "application"
  internal              = false
  vpc_id                = module.ingress_vpc.vpc_id
  subnets               = module.ingress_vpc.public_subnets
  security_groups       = [module.ingress_alb_sg.security_group_id]
  create_security_group = false // don't create new. use existing security group

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"
    }
  ]
  target_groups = [
    {
      name             = "ingress-alb-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      protocol_version = "HTTP1"
      health_check = {
        enabled             = true
        interval            = 5
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 2
      }
    }
  ]
}

module "ingress_alb_sg" {
  source              = "../../../terraform_module/terraform-aws-security-group"
  name                = "ingress-alb-sg"
  description         = "Security group for ingress alb"
  vpc_id              = module.ingress_vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  egress_rules  = ["all-tcp"]
}


# ################################################################################
# # VPC Endpoints for SSM  -- For testing  ===> This needs to be created in seperate VPC where transit gateway exists
# ################################################################################
# module "vpc_endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = "~> 5.0"

#   vpc_id = module.ingress_vpc.vpc_id

#   endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
#     replace(service, ".", "_") =>
#     {
#       service             = service
#       subnet_ids          = module.ingress_vpc.private_subnets
#       private_dns_enabled = true
#       tags                = { Name = "${local.name}-${service}" }
#     }
#   }

#   create_security_group      = true
#   security_group_name_prefix = "${local.name}-vpc-endpoints-"
#   security_group_description = "VPC endpoint security group"
#   security_group_rules = {
#     ingress_https = {
#       description = "HTTPS from subnets"
#     cidr_blocks = module.ingress_vpc.private_subnets_cidr_blocks }
#   }

#   tags = local.tags
# }
