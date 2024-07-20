data "aws_route53_zone" "selected" {
  count = var.use_dns ? 1 : 0

  name = var.domain
}

resource "aws_route53_record" "this" {
  count = var.use_dns ? 1 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = var.alias
  type    = "A"

  alias {
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    name                   = aws_cloudfront_distribution.this.domain_name
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ipv6" {
  count = var.use_dns && var.use_ipv6 ? 1 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = var.alias
  type    = "AAAA"

  alias {
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    name                   = aws_cloudfront_distribution.this.domain_name
    evaluate_target_health = false
  }
}