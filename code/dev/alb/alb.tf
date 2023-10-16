
module "alb" {
  source                = "../../../terraform_module/terraform-aws-alb"
  name                  = "${var.name}-alb"
  load_balancer_type    = "application"
  internal              = true
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets               = data.terraform_remote_state.vpc.outputs.private_subnets
  security_groups       = [data.terraform_remote_state.ec2.outputs.security_group_alb_id]
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
      name_prefix          = "h1"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      protocol_version     = "HTTP1"
      targets = {
        my_ec2 = {
          target_id = data.terraform_remote_state.ec2.outputs.application_ec2_id
          port      = 80
        }
        # multi_ec2_1 = {
        #   target_id = data.terraform_remote_state.ec2.outputs.ec2_multiple.one.id
        #   port      = 80
        # },
        # multi_ec2_2 = {
        #   target_id = data.terraform_remote_state.ec2.outputs.ec2_multiple.two.id
        #   port      = 80
        # }
      }
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
  access_logs = {
    bucket = module.s3-bucket.s3_bucket_id
    prefix = "alb"
  }
}