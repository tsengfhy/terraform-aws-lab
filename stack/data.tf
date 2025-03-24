locals {
  workspace = terraform.workspace

  create_apigateway = length(keys(var.apis)) > 0
  create_ecs        = length(keys(var.services)) > 0
  create_batch      = length(keys(var.jobs)) > 0

  computed_repos = merge(
    local.create_ecs ? {
      ecs = {}
    } : {},
    local.create_batch ? {
      batch = {}
    } : {}
  )
  repos = { for key, value in local.computed_repos : key => merge({
    force_destroy = true
  }, value) }

  computed_secrets = merge(
    local.create_ecs || local.create_batch ? {
      default = {
        secret_keys = ["PASSWORD"]
      }
    } : {}
  )
  secrets = { for key, value in local.computed_secrets : key => merge({
    description   = null
    secret_string = null
    secret_keys   = []
  }, value) }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "log" {
  bucket = "${module.context.global_unique_prefix}-log"
}
