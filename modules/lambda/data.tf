locals {
  service = "lambda"
  use_vpc = length(var.subnet_ids) > 0 || length(var.security_group_ids) > 0
}

data "aws_kms_alias" "log" {
  count = var.logging_settings.kms_alias != null ? 1 : 0

  name = var.logging_settings.kms_alias
}