module "codepipeline" {
  for_each = var.create_codepipeline ? local.repos : {}
  source   = "../modules/codepipeline"

  workspace = local.workspace

  name              = each.key
  service_role_name = one(module.role_codepipeline).id

  artifact_bucket_name = module.s3[var.artifact_bucket_key].id

  stages = flatten([
    [
      {
        name = "source"
        actions = [
          {
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            version          = "1"
            name             = "source"
            namespace        = "SourceVariables"
            output_artifacts = ["source"]
            configuration = {
              ConnectionArn        = one(aws_codeconnections_connection.this).arn
              FullRepositoryId     = lookup(each.value, "repo_name")
              BranchName           = lookup(each.value, "branch_name")
              OutputArtifactFormat = "CODEBUILD_CLONE_REF"
              DetectChanges        = true
            }
          }
        ]
      },
      {
        name = "build"
        actions = [
          {
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            version          = "1"
            name             = "build"
            run_order        = 1
            input_artifacts  = ["source"]
            output_artifacts = ["build"]
            configuration = {
              ProjectName = one(module.codebuild).name
              EnvironmentVariables = jsonencode(flatten([
                lookup(each.value, "type") == "ECS" ? [
                  { name = "CONTAINER_NAME", value = lookup(each.value, "container_name"), type = "PLAINTEXT" },
                  { name = "CONTAINER_PORT", value = lookup(each.value, "container_port"), type = "PLAINTEXT" },
                  { name = "TASK_DEFINITION_NAME", value = module.service[lookup(each.value, "original_key")].task_definition_name, type = "PLAINTEXT" },
                  { name = "ECR_REPOSITORY_URL", value = module.ecr[each.key].url, type = "PLAINTEXT" },
                  { name = "COMMIT_ID", value = "#{SourceVariables.CommitId}", type = "PLAINTEXT" },
                ] : []
              ]))
            }
          },
          {
            category        = "Build"
            owner           = "AWS"
            provider        = "ECRBuildAndPublish"
            version         = "1"
            name            = "publish"
            run_order       = 2
            input_artifacts = ["build"]
            configuration = {
              ECRRepositoryName = module.ecr[each.key].id
              DockerFilePath    = "."
              ImageTags         = "latest,#{SourceVariables.CommitId}"
            }
          }
        ]
      },
    ],
    lookup(each.value, "type") == "ECS" ? [
      {
        name = "approval"
        actions = [
          {
            category = "Approval"
            owner    = "AWS"
            provider = "Manual"
            version  = "1"
            name     = "approval"
            configuration = {
              CustomData         = "Please approve or reject the change: #{SourceVariables.CommitId}, commit message: #{SourceVariables.CommitMessage}"
              ExternalEntityLink = "https://github.com/#{SourceVariables.FullRepositoryName}/commit/#{SourceVariables.CommitId}"
              NotificationArn    = module.sns.arn
            }
          }
        ]
      },
    ] : [],
    lookup(each.value, "type") == "ECS" ? [
      {
        name = "deploy"
        actions = [
          {
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CodeDeployToECS"
            version         = "1"
            name            = "deploy"
            input_artifacts = ["build"]
            configuration = {
              ApplicationName                = module.codedeploy[each.key].app_name
              DeploymentGroupName            = module.codedeploy[each.key].group_name
              AppSpecTemplateArtifact        = "build"
              AppSpecTemplatePath            = "appspec.yaml"
              TaskDefinitionTemplateArtifact = "build"
              TaskDefinitionTemplatePath     = "taskdef.json"
            }
          }
        ]
      },
    ] : [],
  ])
}

resource "aws_codeconnections_connection" "this" {
  count = var.create_codepipeline ? 1 : 0

  name          = "${module.context.prefix}-connection-github"
  provider_type = "GitHub"

  tags = module.context.tags
}

module "codebuild" {
  count  = var.create_codepipeline ? 1 : 0
  source = "../modules/codepipeline/codebuild"

  workspace = local.workspace

  name              = "build"
  service_role_name = one(module.role_codebuild).id
}

module "codedeploy" {
  for_each = var.create_codepipeline ? { for key, value in local.repos : key => value if lookup(value, "type") == "ECS" } : {}
  source   = "../modules/codepipeline/codedeploy"

  workspace = local.workspace

  name                   = each.key
  compute_platform       = "ECS"
  service_role_name      = one(module.role_codedeploy).id
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  use_rollback = true

  ecs_service = {
    cluster_name = one(module.ecs).name
    service_name = module.service[lookup(each.value, "original_key")].name
  }

  load_balancer = {
    prod_listener_arn  = one(module.alb).listener_arn
    target_group_names = module.service[lookup(each.value, "original_key")].target_group_names
  }
}

resource "aws_codestarnotifications_notification_rule" "this" {
  for_each = var.create_codepipeline ? local.repos : {}

  name     = "${module.codepipeline[each.key].name}-notification"
  resource = module.codepipeline[each.key].arn

  detail_type = "FULL"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
  ]

  target {
    address = module.sns.arn
  }

  tags = module.context.tags
}