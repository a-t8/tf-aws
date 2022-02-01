resource "aws_lb" "dev-loadbalancer" {
  name               = "dev-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "dev-tg" {
  name     = "dev-target-group"
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "dev_lb_listener" {
  load_balancer_arn = aws_lb.dev-loadbalancer.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tg.arn
  }
}

resource "aws_route53_record" "a-record-for-alb" {

  zone_id = "Z01699103FKMF8RFA4FA0"
  name = "atul-tiwari.com"
  type = "A"

  alias {
    name = aws_lb.dev-loadbalancer.dns_name
    zone_id = aws_lb.dev-loadbalancer.zone_id
    evaluate_target_health = true
  }
  
}
