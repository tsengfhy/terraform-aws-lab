locals {
  service = "codepipeline"
  name    = "${module.context.prefix}-codepipeline-${var.name}"
}

data "aws_iam_role" "service" {
  name = var.service_role_name
}

data "aws_s3_bucket" "artifact" {
  bucket = var.artifact_bucket_name
}

data "aws_kms_alias" "log" {
  count = var.logging_config.kms_alias != null ? 1 : 0

  name = var.logging_config.kms_alias
}