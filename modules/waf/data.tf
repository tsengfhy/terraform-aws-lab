locals {
  service = "waf"
  name    = "${module.context.prefix}-waf-${var.name}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "log" {
  count = var.use_logging && var.logging_config.kms_alias != null ? 1 : 0

  name = var.logging_config.kms_alias
}