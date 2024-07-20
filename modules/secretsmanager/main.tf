module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_secretsmanager_secret" "this" {
  depends_on = [data.aws_kms_alias.selected]

  name                    = "${module.context.prefix}-secret-${var.name}"
  description             = var.description
  kms_key_id              = data.aws_kms_alias.selected.name
  recovery_window_in_days = 0

  tags = module.context.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = length(var.secret_keys) > 0 ? jsonencode({ for key in var.secret_keys : key => "" }) : var.secret_string

  lifecycle {
    ignore_changes = [secret_string]
  }
}