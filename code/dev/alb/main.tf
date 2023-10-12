provider "aws" {
  region = var.default_region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "ec2" {
  backend = "local"
  config = {
    path = "../ec2/terraform.tfstate"
  }
}

module "alb" {
  source                = "../../../terraform_module/terraform-aws-alb"
  name                  = var.name
  load_balancer_type    = "application"
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets               = data.terraform_remote_state.vpc.outputs.public_subnets
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
        multi_ec2_1 = {
          target_id = data.terraform_remote_state.ec2.outputs.ec2_multiple.one.id
          port      = 80
        },
        multi_ec2_2 = {
          target_id = data.terraform_remote_state.ec2.outputs.ec2_multiple.two.id
          port      = 80
        }
      }
    }
  ]
  access_logs = {
    bucket = module.s3-bucket.s3_bucket_id
    prefix = "alb"
  }
}

module "s3-bucket" {
  source = "../../../terraform_module/terraform-aws-s3-bucket"

  bucket_prefix = "s3-bucket-for-alblogs"
  acl           = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true
}
