locals {
  workspace = terraform.workspace
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "log" {
  bucket = "${local.workspace}-${data.aws_caller_identity.current.account_id}-log"
}
