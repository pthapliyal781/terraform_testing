output "alb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.lb_arn
}
