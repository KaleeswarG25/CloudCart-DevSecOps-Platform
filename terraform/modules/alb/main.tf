# 1. Create the Application Load Balancer
resource "aws_lb" "main_alb" {
  name               = "cloudcart-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids # 👈 This points directly to the list variable

  tags = { Name = "cloudcart-${var.environment}-alb" }
}

# 2. Create the Target Group (Where traffic goes)
resource "aws_lb_target_group" "tg" {
  name        = "cloudcart-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "cloudcart-${var.environment}-tg" }
}

# 3. Create the HTTP Listener on Port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
