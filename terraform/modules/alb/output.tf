output "alb_dns_name" {
  value       = aws_lb.main_alb.dns_name
  description = "The public DNS name of the application load balancer"
}

output "tg_arn" {
  value       = aws_lb_target_group.tg.arn
  description = "The ARN of the target group for the ASG to attach to"
}
