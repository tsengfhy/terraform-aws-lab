resource "aws_secretsmanager_secret" "this" {
  count                   = length(var.task_secrets) > 0 ? 1 : 0
  name                    = "${module.context.prefix}-secrets-ecs"
  kms_key_id              = data.aws_kms_key.secretsmanager.arn
  recovery_window_in_days = 0

  tags = module.context.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = length(var.task_secrets) > 0 ? 1 : 0
  secret_id     = one(aws_secretsmanager_secret.this).id
  secret_string = jsonencode({ for key in var.task_secrets : key => "placeholder..." })

  lifecycle {
    ignore_changes = [secret_string]
  }
}