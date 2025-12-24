output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of target group for Auto Scaling attachment"
  value       = aws_lb_target_group.main.arn
}