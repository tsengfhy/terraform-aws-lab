module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_codebuild_project" "this" {
  name         = local.name
  service_role = data.aws_iam_role.service.arn

  environment {
    type            = var.environment.type
    image           = var.environment.image
    compute_type    = var.environment.compute_type
    certificate     = var.environment.certificate
    privileged_mode = var.use_docker

    dynamic "environment_variable" {
      for_each = var.envs

      content {
        name  = environment_variable.value.name
        type  = environment_variable.value.type
        value = environment_variable.value.value
      }
    }
  }

  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [0] : []

    content {
      vpc_id             = var.vpc_config.vpc_id
      subnets            = var.vpc_config.subnets
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  source {
    type      = var.source_config.type
    location  = var.source_config.location
    buildspec = var.source_config.buildspec
  }

  artifacts {
    type      = var.artifacts_config.type
    location  = var.artifacts_config.location
    path      = var.artifacts_config.path
    packaging = var.artifacts_config.packaging
  }

  dynamic "cache" {
    for_each = var.use_caching ? [0] : []

    content {
      type     = "S3"
      location = one(data.aws_s3_bucket.cache).bucket
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.this.name
      stream_name = local.service
    }
  }

  tags = module.context.tags
}