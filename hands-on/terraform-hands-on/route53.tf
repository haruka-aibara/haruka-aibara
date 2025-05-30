# ------------------------
# Route53
# ------------------------
resource "aws_route53_zone" "route53_zone" {
  name          = var.domain
  force_destroy = false

  tags = {
    Name    = "${var.project}-${var.environment}-domain"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_route53_record" "route53_record" {
  name    = "dev-elb.${var.domain}"
  type    = "A"
  zone_id = aws_route53_zone.route53_zone.id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
  }
}