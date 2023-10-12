
output "application_ec2_id" {
  description = "The ID of the instance"
  value       = module.application_ec2.id
}

output "security_group_alb_id" {
  description = "The ID of the security group"
  value       = module.security_group_alb.security_group_id
}

output "ec2_multiple" {
  description = "The full output of the `ec2_module` module"
  value       = module.multi_ec2
}