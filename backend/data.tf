locals {
  workspace = terraform.workspace
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "s3" {
  name = var.s3_kms_alias
}