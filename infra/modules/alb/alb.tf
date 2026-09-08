resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  subnets = [aws_subnet.subnet-1.id,aws_subnet.subnet-2.id]
  security_groups = [aws_security_group.web-sg.id,aws_security_group.self-rf.id]
  

}





resource "aws_lb_target_group" "tg-ip" {
  name        = "tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
  health_check {
    path = "/health"


  }
}


resource "aws_lb_listener" "listener-https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ip.arn
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