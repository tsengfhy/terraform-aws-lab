resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/${local.service}/${var.workspace}/${var.name}"
  retention_in_days = var.logging_settings.retention_in_days
  kms_key_id        = try(one(data.aws_kms_alias.log).target_key_arn, null)
  skip_destroy      = var.logging_settings.skip_destroy

  tags = module.context.tags
}