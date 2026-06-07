output "vpc_id" {
  value = aws_vpc.cloudcart_vpc.id
}

output "subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

# STEP 7: Add your private subnet outputs here
output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}
