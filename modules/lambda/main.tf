module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_lambda_function" "this" {
  function_name = "${module.context.prefix}-lambda-function-${var.name}"
  role          = module.role.arn

  package_type     = var.image_uri != null ? "Image" : "Zip"
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  image_uri        = var.image_uri
  source_code_hash = var.filename != null && var.source_code_hash == null ? filebase64sha256(var.filename) : var.source_code_hash
  layers           = var.layers

  runtime                        = var.runtime
  architectures                  = [var.architecture]
  handler                        = var.handler
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  timeout                        = var.timeout

  ephemeral_storage {
    size = var.ephemeral_storage
  }

  environment {
    variables = { for item in var.envs : item.name => item.value }
  }

  dynamic "vpc_config" {
    for_each = local.use_vpc ? [0] : []

    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  replace_security_groups_on_destroy = local.use_vpc

  dynamic "dead_letter_config" {
    for_each = var.use_dlq ? [0] : []

    content {
      target_arn = one(module.dlq).arn
    }
  }

  logging_config {
    log_format            = "JSON"
    log_group             = aws_cloudwatch_log_group.this.name
    system_log_level      = var.logging_settings.system_level
    application_log_level = var.logging_settings.application_level
  }

  tags = module.context.tags

  lifecycle {
    precondition {
      condition = (
        (var.filename != null ? 1 : 0) +
        (var.s3_bucket != null ? 1 : 0) +
        (var.image_uri != null ? 1 : 0)
      ) == 1
      error_message = "Exactly one of filename, image_uri, or s3_bucket must be specified"
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.use_dlq ? 1 : 0

  function_name = aws_lambda_function.this.arn

  maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
  maximum_retry_attempts       = var.maximum_retry_attempts
}