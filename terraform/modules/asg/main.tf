

# Fetch the latest official Amazon Linux 2 AMI dynamically
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# The configuration blueprint for any instance spawned by the cluster
resource "aws_launch_template" "asg_template" {
  name_prefix   = "cloudcart-${var.environment}-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  # Automatically boots up Docker and runs the app container on startup
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              sudo docker run -d -p 80:80 --name cloudcart-app nginx
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# The Auto Scaling Engine driving elasticity across subnets
resource "aws_autoscaling_group" "main_asg" {
  name_prefix         = "cloudcart-${var.environment}-asg-"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn] # Chains directly into your ALB!

  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 120

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "cloudcart-${var.environment}-asg-worker"
    propagate_at_launch = true
  }
}
