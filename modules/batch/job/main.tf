module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_batch_job_definition" "this" {
  name                  = "${module.context.prefix}-batch-job-${var.name}"
  platform_capabilities = ["FARGATE"]
  type                  = "container"

  container_properties = jsonencode({
    executionRoleArn = data.aws_iam_role.task_execution.arn
    jobRoleArn       = data.aws_iam_role.task.arn
    image            = "${data.aws_ecr_repository.selected.repository_url}:${var.ecr_image_tag}"
    environment      = var.envs
    secrets          = var.secrets

    resourceRequirements = [
      {
        type  = "VCPU"
        value = var.vcpu
      },
      {
        type  = "MEMORY"
        value = var.memory
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = data.aws_region.current.name
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-stream-prefix = local.service
      }
    }
  })

  timeout {
    attempt_duration_seconds = var.attempt_duration_seconds
  }

  tags = module.context.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/${local.service}/${var.workspace}/${var.name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = try(one(data.aws_kms_alias.log).target_key_arn, null)
  skip_destroy      = var.log_skip_destroy

  tags = module.context.tags
}