locals {
  service               = "apigateway"
  use_caching           = var.caching_config.size != null
  use_execution_logging = var.logging_config.level != "OFF"
}

data "aws_kms_alias" "log" {
  count = var.logging_config.kms_alias != null ? 1 : 0

  name = var.logging_config.kms_alias
}