variable "environment" {
  type        = string
  description = "The deployment environment name (workspace)"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the target VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of public subnets for the load balancer"
}

variable "security_group_id" {
  type        = string
  description = "The security group to apply to the ALB"
}
