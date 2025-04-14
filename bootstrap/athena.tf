resource "aws_athena_workgroup" "primary" {
  count = var.use_athena ? 1 : 0

  name          = "primary"
  force_destroy = false

  configuration {
    publish_cloudwatch_metrics_enabled = true
    enforce_workgroup_configuration    = true

    result_configuration {
      output_location       = "s3://${one(module.s3_athena).id}/"
      expected_bucket_owner = data.aws_caller_identity.current.account_id
    }
  }

  tags = module.context.tags

  lifecycle {
    ignore_changes = [state]
  }
}

module "s3_athena" {
  count  = var.use_athena ? 1 : 0
  source = "../modules/s3"

  workspace = local.workspace

  name                  = "athena-query-results"
  force_destroy         = true
  use_default_lifecycle = true
}

