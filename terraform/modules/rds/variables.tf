variable "environment" {}
variable "subnet_ids" {}
variable "security_group_id" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
