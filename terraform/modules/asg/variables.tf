variable "environment" {
  type        = string
  description = "The deployment environment name (workspace)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets where the ASG should launch instances"
}

variable "security_group_id" {
  type        = string
  description = "The security group to apply to the instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size"
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the ALB target group to link to"
}
