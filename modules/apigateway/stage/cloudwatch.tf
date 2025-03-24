resource "aws_cloudwatch_log_group" "execution" {
  count = local.use_execution_logging ? 1 : 0

  name              = "API-Gateway-Execution-Logs_${var.rest_api_id}/${var.name}"
  retention_in_days = var.logging_settings.retention_in_days
  kms_key_id        = try(one(data.aws_kms_alias.log).target_key_arn, null)
  skip_destroy      = var.logging_settings.skip_destroy

  tags = module.context.tags
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "/aws/${local.service}/${var.workspace}/${var.rest_api_id}/${var.name}"
  retention_in_days = var.logging_settings.retention_in_days
  kms_key_id        = try(one(data.aws_kms_alias.log).target_key_arn, null)
  skip_destroy      = var.logging_settings.skip_destroy

  tags = module.context.tags
}