# output "public_route_table_ids" {
#   description = "List of IDs of public route tables"
#   value       = module.vpc.public_route_table_ids
# }

# output "ingress_private_route_table_ids" {
#   description = "List of IDs of private route tables"
#   value       = module.ingress_vpc.private_route_table_ids
# }

output "ingress_vpc_id" {
  description = "ID of the ingress VPC"
  value       = module.ingress_vpc.vpc_id
}

output "ingress_vpc_private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.ingress_vpc.private_route_table_ids
}

output "ingress_vpc_public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.ingress_vpc.public_route_table_ids
}

output "inspection_vpc_private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.inspection_vpc.private_route_table_ids
}

output "egress_vpc_private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.egress_vpc.private_route_table_ids
}

output "egress_vpc_public_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.egress_vpc.public_route_table_ids
}

output "ec2_transit_gateway_id" {
  description = "EC2 Transit Gateway identifier"
  value       = module.transit_gateway.ec2_transit_gateway_id
}

output "ec2_transit_gateway_route_table_id" {
  description = "EC2 Transit Gateway Route Table identifier"
  value       = module.transit_gateway.ec2_transit_gateway_route_table_id
}
