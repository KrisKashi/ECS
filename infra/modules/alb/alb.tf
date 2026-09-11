resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = var.security_group_ids
  

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
}


resource "aws_lb_listener" "listener-https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ip.arn ## connect to ecs
  }
}

resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"               # This listener forces https by redirecting http traffic to https

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}