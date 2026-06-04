output "asg_name" {
  value       = aws_autoscaling_group.main_asg.name
  description = "The name of the Auto Scaling Group"
}

output "asg_arn" {
  value       = aws_autoscaling_group.main_asg.arn
  description = "The ARN of the Auto Scaling Group"
}
