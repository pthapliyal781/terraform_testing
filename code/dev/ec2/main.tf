provider "aws" {
  region = var.default_region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  # name = "ex-${basename(path.cwd)}"
  name = "dev-ec2"
  tags = {
    Name = local.name
  }
}

module "application_ec2" {
  source        = "../../../terraform_module/terraform-aws-ec2-instance"
  name          = var.name
  ami           = data.aws_ami.amazon_linux.id
  subnet_id     = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  instance_type = var.instance_type
  monitoring    = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [module.security_group_instance.security_group_id]

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "my-root-block"
      }
    }
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = true
      kms_key_id  = data.aws_kms_alias.aws_ebs.id
      tags = {
        Name       = "my-ebs-block"
        MountPoint = "/mnt/data"
      }
    }
  ]

  user_data_base64 = base64encode(file("httpd.sh"))
  user_data_replace_on_change = true

  enable_volume_tags = false

}



# Configuration for multiple instances
locals {
  multiple_instances = {
    one = {
      instance_type = "t3.micro"
      subnet_id     = data.terraform_remote_state.vpc.outputs.private_subnets[0]
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 50
          tags = {
            Name = "my-root-block"
          }
        }
      ]
    }
    two = {
      instance_type = "t3.small"
      subnet_id     = data.terraform_remote_state.vpc.outputs.private_subnets[1]

      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp2"
          volume_size = 50
        }
      ]
    }
  }
}

# Create multiple instances 
module "multi_ec2" {
  create = false # don't create any instances
  source                 = "../../../terraform_module/terraform-aws-ec2-instance"
  for_each               = local.multiple_instances
  name                   = "${local.name}-multi-${each.key}"
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [module.security_group_instance.security_group_id]

  enable_volume_tags = false
  root_block_device  = lookup(each.value, "root_block_device", [])

}

module "security_group_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-alb"
  description = "Security Group for ALB"

  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["http-80-tcp"]

  tags = var.tags
}

module "security_group_instance" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-ec2"
  description = "Security Group for EC2 Instance Egress"

  ingress_with_source_security_group_id = [
    {
      description              = "Allow all inbound traffic from the ALB"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.security_group_alb.security_group_id
    }
  ]
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  egress_rules = ["http-80-tcp", "https-443-tcp"]

  tags = var.tags
}

################################################################################
# KMS Key
################################################################################
resource "aws_kms_key" "this" {
  description = "KMS key for EC2 instance"
}

data "aws_kms_alias" "aws_ebs" {
  name  = "alias/aws/ebs"
}

################################################################################
# VPC Endpoints for SSM
################################################################################
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = data.terraform_remote_state.vpc.outputs.private_subnets
      private_dns_enabled = true
      tags                = { Name = "${local.name}-${service}" }
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}

