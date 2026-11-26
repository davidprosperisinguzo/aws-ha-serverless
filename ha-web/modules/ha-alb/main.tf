# Application Load Balancer
resource "aws_lb" "ha_alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb"
  })
}

# Target Group for application instances (port 3000)
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.name_prefix}-app-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-tg"
  })
}

# HTTP Listener on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ha_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}