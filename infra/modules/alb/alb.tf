resource "aws_lb" "alb" {
  name                       = "alb"
  load_balancer_type         = "application"
  subnets                    = var.subnet_ids
  security_groups            = [aws_security_group.web-sg.id, var.self_sg]
  drop_invalid_header_fields = true
  tags = {
    Name = "gatus_alb"
  }
}

resource "aws_lb_target_group" "tg-ip" {
  name        = "tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path = "/health"
  }
  tags = {
    Name = "gatus_target_group"
  }
}


resource "aws_lb_listener" "listener-https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ip.arn ## connect to ecs
  }
  tags = {
    Name = "gatus_alb_https_listener"
  }
}

resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect" # This listener forces https by redirecting http traffic to https

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "gatus_alb_http_listener"
  }
}

resource "aws_security_group" "web-sg" { # Security group 1 Client to  ALB
  name   = "web-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80 #http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { #https
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "gatus_alb_sg"
  }
}
