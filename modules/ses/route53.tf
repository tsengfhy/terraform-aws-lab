data "aws_route53_zone" "selected" {
  count = var.use_dns ? 1 : 0

  name = var.domain
}

resource "aws_route53_record" "dkim" {
  count = var.use_dns ? 3 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = "${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = 1800
  records = ["${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "spf" {
  count = var.use_dns && var.use_spf ? 1 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = var.mail_from_alias
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "mx" {
  count = var.use_dns && var.use_spf ? 1 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = var.mail_from_alias
  type    = "MX"
  ttl     = 300
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

resource "aws_route53_record" "dmarc" {
  count = var.use_dns ? 1 : 0

  zone_id = one(data.aws_route53_zone.selected).zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1; p=none;"]
}