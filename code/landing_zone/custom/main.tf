
provider "aws" {
  region = var.default_region
}

data "terraform_remote_state" "dev_vpc" {
  backend = "local"
  config = {
    path = "../../dev/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "transit_gateway" {
  backend = "local"
  config = {
    path = "../transit-gateway/terraform.tfstate"
  }
}

# Custom routes for transit gateway private connections in ingress VPC
resource "aws_route" "ingress_transit_gateway_private_routes" {
  for_each = toset(data.terraform_remote_state.transit_gateway.outputs.ingress_vpc_private_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_id

}

# Custom routes for transit gateway public connections in ingress VPC
resource "aws_route" "ingress_transit_gateway_public_routes" {
  for_each = toset(data.terraform_remote_state.transit_gateway.outputs.ingress_vpc_public_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = var.super_cidr
  transit_gateway_id     = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_id

}

# Custom routes for transit gateway public connections in egress VPC
resource "aws_route" "egress_transit_gateway_public_routes" {
  for_each = toset(data.terraform_remote_state.transit_gateway.outputs.egress_vpc_public_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = var.super_cidr
  transit_gateway_id     = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_id

}

# Custom routes for transit gateway private connections in inspection VPC
resource "aws_route" "inspection_transit_gateway_private_routes" {
  for_each = toset(data.terraform_remote_state.transit_gateway.outputs.inspection_vpc_private_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_id

}

# Custom routes for transit gateway private connections in dev_vpc VPC
resource "aws_route" "dev_vpc_transit_gateway_private_route" {
  for_each = toset(data.terraform_remote_state.dev_vpc.outputs.private_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_id

}

# VPC attachment for transit gateway with dev vpc
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc" {
  subnet_ids                                      = data.terraform_remote_state.dev_vpc.outputs.private_subnets
  transit_gateway_id                              = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_id
  vpc_id                                          = data.terraform_remote_state.dev_vpc.outputs.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "dev_vpc"
  }
}

# route table association for transit gateway with dev vpc
resource "aws_ec2_transit_gateway_route_table_association" "dev_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc.id
  transit_gateway_route_table_id = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_route_table_id
}

# route table propogation for trasit gateway with dev vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "dev_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc.id
  transit_gateway_route_table_id = data.terraform_remote_state.transit_gateway.outputs.ec2_transit_gateway_route_table_id
}