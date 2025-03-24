data "aws_route53_zone" "selected" {
  count = var.use_dns ? 1 : 0

  name = var.domain
}

data "aws_acm_certificate" "selected" {
  count = var.type != "EDGE" ? 1 : 0

  domain   = var.domain
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "global" {
  count    = var.type == "EDGE" ? 1 : 0
  provider = aws.global

  domain   = var.domain
  statuses = ["ISSUED"]
}