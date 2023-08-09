locals {
  workspace = terraform.workspace
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "s3" {
  key_id = var.s3_kms_key_id
}