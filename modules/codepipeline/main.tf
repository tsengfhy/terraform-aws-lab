module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_codepipeline" "this" {
  name           = local.name
  pipeline_type  = "V2"
  execution_mode = var.execution_mode
  role_arn       = data.aws_iam_role.service.arn

  artifact_store {
    type     = "S3"
    location = data.aws_s3_bucket.artifact.bucket

    encryption_key {
      type = "KMS"
      id   = var.artifact_kms_alias
    }
  }

  dynamic "variable" {
    for_each = var.variables

    content {
      name          = variable.value.name
      default_value = variable.value.default_value
      description   = variable.value.description
    }
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name = stage.value.name

      dynamic "action" {
        for_each = stage.value.actions

        content {
          category         = action.value.category
          owner            = action.value.owner
          provider         = action.value.provider
          version          = action.value.version
          name             = action.value.name
          region           = action.value.region
          run_order        = action.value.run_order
          role_arn         = action.value.role_arn
          namespace        = action.value.namespace
          input_artifacts  = action.value.input_artifacts
          output_artifacts = action.value.output_artifacts
          configuration    = action.value.configuration
        }
      }
    }
  }

  dynamic "trigger" {
    for_each = var.triggers

    content {
      provider_type = "CodeStarSourceConnection"

      git_configuration {
        source_action_name = trigger.value.source_action_name

        dynamic "pull_request" {
          for_each = trigger.value.pull_request != null ? [0] : []

          content {
            events = trigger.value.pull_request.events

            dynamic "branches" {
              for_each = trigger.value.pull_request.branches != null ? [0] : []

              content {
                includes = trigger.value.pull_request.branches.includes
                excludes = trigger.value.pull_request.branches.excludes
              }
            }

            dynamic "file_paths" {
              for_each = trigger.value.pull_request.file_paths != null ? [0] : []

              content {
                includes = trigger.value.pull_request.file_paths.includes
                excludes = trigger.value.pull_request.file_paths.excludes
              }
            }
          }
        }

        dynamic "push" {
          for_each = trigger.value.push != null ? [0] : []

          content {
            dynamic "branches" {
              for_each = trigger.value.push.branches != null ? [0] : []

              content {
                includes = trigger.value.push.branches.includes
                excludes = trigger.value.push.branches.excludes
              }
            }

            dynamic "file_paths" {
              for_each = trigger.value.push.file_paths != null ? [0] : []

              content {
                includes = trigger.value.push.file_paths.includes
                excludes = trigger.value.push.file_paths.excludes
              }
            }

            dynamic "tags" {
              for_each = trigger.value.push.tags != null ? [0] : []

              content {
                includes = trigger.value.push.tags.includes
                excludes = trigger.value.push.tags.excludes
              }
            }
          }
        }
      }
    }
  }

  tags = module.context.tags
}