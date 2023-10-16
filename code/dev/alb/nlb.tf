module "nlb" {
  source             = "../../../terraform_module/terraform-aws-alb"
  name               = "${var.name}-nlb"
  load_balancer_type = "network"
  internal           = true
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  # subnets            = data.terraform_remote_state.vpc.outputs.private_subnets
  subnet_mapping = [
    {
      subnet_id            = data.terraform_remote_state.vpc.outputs.private_subnets[0]
      private_ipv4_address = "10.10.2.10"
    },
    {
      subnet_id            = data.terraform_remote_state.vpc.outputs.private_subnets[1]
      private_ipv4_address = "10.10.12.10"
    },
  ]

  # TCP_UDP, UDP, TCP
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
  ]
  target_groups = [
    {
      name                 = "${var.name}-nlb-tg"
      backend_protocol     = "TCP"
      backend_port         = 80
      target_type          = "alb"
      deregistration_delay = 10
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

  tags = var.tags

}

resource "aws_lb_target_group_attachment" "nlb_tga" {
  target_group_arn = module.nlb.target_group_arns[0]
  target_id        = module.alb.lb_arn
  port             = 80
}
