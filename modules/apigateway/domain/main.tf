module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name = "${var.alias}.${var.domain}"

  endpoint_configuration {
    types = [var.type]
  }

  certificate_arn          = var.type == "EDGE" ? one(data.aws_acm_certificate.global).arn : null
  regional_certificate_arn = var.type != "EDGE" ? one(data.aws_acm_certificate.selected).arn : null
  security_policy          = "TLS_1_2"
  policy                   = var.policy

  tags = module.context.tags
}

resource "aws_api_gateway_domain_name_access_association" "this" {
  for_each = toset(var.vpc_endpoint_ids)

  domain_name_arn                = aws_api_gateway_domain_name.this.arn
  access_association_source_type = "VPCE"
  access_association_source      = each.key
}