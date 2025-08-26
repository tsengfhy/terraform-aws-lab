module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_sfn_state_machine" "this" {
  name     = local.name
  role_arn = module.role.arn

  type       = var.type
  publish    = true
  definition = var.definition

  logging_configuration {
    level                  = var.logging_config.level
    include_execution_data = var.logging_config.include_execution_data
    log_destination        = "${aws_cloudwatch_log_group.this.arn}:*"
  }

  tracing_configuration {
    enabled = var.use_xray
  }

  tags = module.context.tags
}



