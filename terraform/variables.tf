variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
