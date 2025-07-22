locals {
  service = "codebuild"
  name    = "${module.context.prefix}-codebuild-${var.name}"
}

data "aws_iam_role" "service" {
  name = var.service_role_name
}

data "aws_s3_bucket" "cache" {
  count = var.use_caching ? 1 : 0

  bucket = var.caching_bucket_name
}

data "aws_kms_alias" "log" {
  count = var.logging_config.kms_alias != null ? 1 : 0

  name = var.logging_config.kms_alias
}