data "aws_caller_identity" "current" {}

data "aws_kms_alias" "selected" {
  count = var.use_kms ? 1 : 0

  name = var.kms_alias
}

data "aws_s3_bucket" "log" {
  count = var.use_logging ? 1 : 0

  bucket = var.log_bucket_name
}