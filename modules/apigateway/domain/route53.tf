resource "aws_route53_record" "this" {
  count = var.use_dns ? 1 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = var.alias
  type    = "A"

  alias {
    zone_id                = var.type == "EDGE" ? aws_api_gateway_domain_name.this.cloudfront_zone_id : aws_api_gateway_domain_name.this.regional_zone_id
    name                   = var.type == "EDGE" ? aws_api_gateway_domain_name.this.cloudfront_domain_name : aws_api_gateway_domain_name.this.regional_domain_name
    evaluate_target_health = true
  }
}