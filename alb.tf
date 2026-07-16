resource "aws_lb" "internal" {
  name               = var.project_name
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.internal.id,
    aws_security_group.cf-to-alb.id,
  ]
  subnets = [
    aws_subnet.private-a.id,
    aws_subnet.private-b.id,
    aws_subnet.private-c.id
  ]

  tags = {
    Name = "${var.project_name}-internal-alb"
  }
}

resource "aws_lb_target_group" "nginx" {
  name                 = "${var.project_name}-nginx"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  target_type          = "ip"
  deregistration_delay = "30"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      # message_body = "Connection refused"
      status_code = "444"
    }
  }
}

resource "aws_lb_listener_rule" "cloudfront_only" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  condition {
    http_header {
      http_header_name = local.custom-header-name
      values           = [random_password.custom-header-value.result]
    }
  }
}
