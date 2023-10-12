provider "aws" {
  region = var.default_region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

module "rds" {
  source     = "../../../terraform_module/terraform-aws-rds"
  identifier = var.name
  username   = "admin"
  db_name    = "mydb"

  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.db_subnet_group_name
  engine                 = "mysql"
  engine_version         = "8.0"
  family                 = "mysql8.0" # DB parameter group
  major_engine_version   = "8.0"      # DB option group
  instance_class         = "db.t4g.large"
  allocated_storage      = 20
  max_allocated_storage  = 100
  backup_window          = "03:00-06:00"
  vpc_security_group_ids = [module.security_group_rds.security_group_id]


}

module "security_group_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-rds"
  description = "Security Group for RDS"

  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_cidr_blocks = data.terraform_remote_state.vpc.outputs.database_subnets_cidr_blocks
  ingress_rules       = ["mysql-tcp"]
  # egress_rules = ["all-tcp"]

  tags = var.tags
}