
module "transit_gateway" {
  source          = "../../../terraform_module/terraform-aws-transit-gateway"
  name            = var.name
  amazon_side_asn = 64532
  share_tgw       = false

  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    ingress_vpc = {
      vpc_id                                          = module.ingress_vpc.vpc_id
      subnet_ids                                      = module.ingress_vpc.private_subnets #, module.ingress_vpc.public_subnets)
      dns_support                                     = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = {
        "Name" = "ingress_vpc"
      }

    },
    egress_vpc = {
      vpc_id                                          = module.egress_vpc.vpc_id
      subnet_ids                                      = module.egress_vpc.private_subnets
      dns_support                                     = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tgw_routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
      tags = {
        "Name" = "egress_vpc"
      }
    },
    inspection_vpc = {
      vpc_id                                          = module.inspection_vpc.vpc_id
      subnet_ids                                      = module.inspection_vpc.private_subnets
      dns_support                                     = true
      appliance_mode_support                          = true
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = {
        "Name" = "inspection_vpc"
      }
    }
  }
}