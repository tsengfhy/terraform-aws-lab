module "context" {
  source = "../context"

  environment = var.environment
}

resource "aws_batch_compute_environment" "this" {
  compute_environment_name = "${module.context.prefix}-batch"
  type                     = "MANAGED"
  service_role             = data.aws_iam_role.batch_role.arn

  compute_resources {
    type               = var.capacity_provider
    max_vcpus          = 256
    security_group_ids = concat([aws_security_group.job.id], var.security_group_ids)
    subnets            = data.aws_subnet_ids.private.ids
  }

  tags = module.context.tags
}

resource "aws_batch_job_queue" "this" {
  name                 = "${module.context.prefix}-batch-queue"
  compute_environments = [aws_batch_compute_environment.this.arn]
  state                = "ENABLED"
  priority             = 100

  tags = module.context.tags
}

resource "aws_batch_job_definition" "this" {
  for_each              = var.jobs
  name                  = "${module.context.prefix}-batch-job-${each.key}"
  platform_capabilities = ["FARGATE"]
  type                  = "container"

  container_properties = jsonencode({
    image            = "${aws_ecr_repository.this.repository_url}:latest"
    executionRoleArn = data.aws_iam_role.job_execution_role.arn
    jobRoleArn       = data.aws_iam_role.job_role.arn

    resourceRequirements = [
      {
        type  = "VCPU"
        value = each.value.vcpu != null ? each.value.vcpu : var.job_vcpu
      },
      {
        type  = "MEMORY"
        value = each.value.memory != null ? each.value.memory : var.job_memory
      }
    ]

    environment = [
      {
        name  = var.job_name_key
        value = each.key
      },
      {
        name  = var.job_env_key
        value = var.environment
      },
    ]

    secrets = [
      for key in var.job_secrets : {
        name      = key,
        valueFrom = "${one(aws_secretsmanager_secret.this).arn}:${key}::"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-region        = data.aws_region.current.name
        awslogs-group         = "/batch/${var.environment}"
        awslogs-stream-prefix = each.key
      }
    }
  })

  timeout {
    attempt_duration_seconds = var.job_attempt_duration_seconds
  }

  tags = module.context.tags
}



