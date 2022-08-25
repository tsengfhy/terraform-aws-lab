locals {
  environment     = terraform.workspace
  lob_bucket_name = "${module.context.global_prefix}-logs"

  create_endpoints = var.create_ecs || var.create_batch
}

data "aws_region" "current" {}

data "aws_caller_identity" "this" {}
