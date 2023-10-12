
module "tgw" {
  source                                = "terraform-aws-modules/transit-gateway/aws"
  version                               = "~> 2.0"
  name                                  = var.name
  enable_auto_accept_shared_attachments = true

  vpc_attachments  = {
    vpc =  {
      vpc_id = module.egress_vpc.vpc_id
      subnet_ids = module.egress_vpc.private_subnets
      dns_support = true
      
    }
  }
}