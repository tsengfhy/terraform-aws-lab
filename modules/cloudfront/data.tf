locals {
  default_origin_id = "default"
}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "selected" {
  count = var.use_dns ? 1 : 0

  domain   = var.domain
  statuses = ["ISSUED"]

  provider = aws.global
}

data "aws_s3_bucket" "log" {
  count = var.use_logging ? 1 : 0

  bucket = var.log_bucket_name
}