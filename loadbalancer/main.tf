resource "aws_lb" "dev-loadbalancer" {
  name               = "dev-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "dev-tg" {
  name     = "dev-target-group-dev-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "dev_lb_listener" {
  load_balancer_arn = aws_lb.dev-loadbalancer.arn
  port              = var.port
  protocol          = var.protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.acm-validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tg.arn
  }
}

resource "aws_route53_record" "a-record-for-alb" {

  zone_id = data.aws_route53_zone.atul-tiwari_com.zone_id
  name    = "atul-tiwari.com"
  type    = "A"

  alias {
    name                   = aws_lb.dev-loadbalancer.dns_name
    zone_id                = aws_lb.dev-loadbalancer.zone_id
    evaluate_target_health = true
  }

}
resource "aws_acm_certificate" "ssl-cert-for-alb" {
  domain_name               = "atul-tiwari.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.atul-tiwari.com"]

  tags = {
    Environment = "dev"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "cert-validations" {
  for_each = {
    for rec in aws_acm_certificate.ssl-cert-for-alb.domain_validation_options : rec.domain_name => {
      name   = rec.resource_record_name
      record = rec.resource_record_value
      type   = rec.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.atul-tiwari_com.zone_id

}
data "aws_route53_zone" "atul-tiwari_com" {
  name         = "atul-tiwari.com"
  private_zone = false
}
resource "aws_acm_certificate_validation" "acm-validation" {
  certificate_arn         = aws_acm_certificate.ssl-cert-for-alb.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validations : record.fqdn]


}
