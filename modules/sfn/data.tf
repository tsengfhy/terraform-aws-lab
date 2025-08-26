locals {
  service = "sfn"
  name    = "${module.context.prefix}-sfn-${var.name}"
}

data "aws_kms_alias" "log" {
  count = var.logging_config.kms_alias != null ? 1 : 0

  name = var.logging_config.kms_alias
}