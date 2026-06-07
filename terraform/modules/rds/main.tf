resource "aws_db_subnet_group" "main" {
  name = "cloudcart-${var.environment}-db-subnet"

  subnet_ids = var.subnet_ids

  tags = {
    Name = "cloudcart-db-subnet"
  }
}

resource "aws_db_instance" "mysql" {

  identifier = "cloudcart-${var.environment}"

  allocated_storage = 20

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  username = var.db_username
  password = var.db_password

  publicly_accessible = false

  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    var.security_group_id
  ]
}
