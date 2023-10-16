
# Custom routes for transit gateway private connections in ingress VPC
resource "aws_route" "ingress_tgw_private_route" {
  for_each = toset(module.ingress_vpc.private_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.ingress_vpc.private_route_table_ids, module.tgw.ec2_transit_gateway_id]
}

# Custom routes for transit gateway public connections in ingress VPC
resource "aws_route" "ingress_tgw_public_route" {
  for_each = toset(module.ingress_vpc.public_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = var.super_cidr
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.ingress_vpc.public_route_table_ids, module.tgw.ec2_transit_gateway_id]
}


# # Custom routes for transit gateway private connections in egress VPC
# resource "aws_route" "egress_tgw_private_route" {
#   for_each = toset(module.egress_vpc.private_route_table_ids)

#   route_table_id         = each.key
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = module.tgw.ec2_transit_gateway_id

#   depends_on = [module.egress_vpc.private_route_table_ids, module.tgw.ec2_transit_gateway_id]
# }


# Custom routes for transit gateway private connections in inspection VPC
resource "aws_route" "inspection_tgw_private_route" {
  for_each = toset(module.inspection_vpc.private_route_table_ids)

  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id

  depends_on = [module.inspection_vpc.private_route_table_ids, module.tgw.ec2_transit_gateway_id]
}
