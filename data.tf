locals {
  environment     = terraform.workspace
  lob_bucket_name = "default-${data.aws_caller_identity.this.account_id}-logs"

  create_endpoints = var.create_ecs || var.create_batch
}

data "aws_region" "current" {}

data "aws_caller_identity" "this" {}
