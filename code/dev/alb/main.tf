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
