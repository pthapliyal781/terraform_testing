# Temporary AWS ALB resource
module "alb" {
  source             = "../../../terraform_module/terraform-aws-alb"
  name               = "alb"
  load_balancer_type = "application"
  vpc_id             = module.ingress_vpc.vpc_id
  subnets            = module.ingress_vpc.public_subnets

  create_security_group = true
  security_group_rules = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type        = "fixed-response"
      target_group_index = 0
      fixed_response = {
        content_type = "text/plain"
        message_body = "Hello PCT...!"
        status_code  = "200"
      }
    }
  ]

  target_groups = [
    {
      name                 = "tg"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      protocol_version     = "HTTP1"
    }
  ]
}
