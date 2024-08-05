resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.id
}

resource "aws_ses_domain_mail_from" "this" {
  count = var.use_spf ? 1 : 0

  domain           = aws_ses_domain_identity.this.id
  mail_from_domain = "${var.mail_from_alias}.${aws_ses_domain_identity.this.id}"
}

resource "aws_ses_domain_identity_verification" "this" {
  depends_on = [aws_route53_record.dkim]
  count      = var.use_dns ? 1 : 0

  domain = aws_ses_domain_identity.this.id
}