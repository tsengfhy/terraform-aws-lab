data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "selected" {
  count = var.use_kms ? 1 : 0

  name = var.kms_alias
}