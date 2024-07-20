module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_acm_certificate" "this" {
  depends_on = [data.aws_route53_zone.selected]

  domain_name       = var.domain
  validation_method = "DNS"

  subject_alternative_names = ["*.${var.domain}"]

  tags = module.context.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.this.fqdn]
}

resource "aws_route53_record" "this" {
  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = element(tolist(aws_acm_certificate.this.domain_validation_options), 0).resource_record_name
  type            = element(tolist(aws_acm_certificate.this.domain_validation_options), 0).resource_record_type
  ttl             = 300
  records         = [element(tolist(aws_acm_certificate.this.domain_validation_options), 0).resource_record_value]
  allow_overwrite = true
}