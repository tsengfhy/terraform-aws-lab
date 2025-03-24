locals {
  service               = "apigateway"
  use_caching           = var.caching_settings.size != null
  use_execution_logging = var.logging_settings.level != "OFF"
}

data "aws_kms_alias" "log" {
  count = var.logging_settings.kms_alias != null ? 1 : 0

  name = var.logging_settings.kms_alias
}