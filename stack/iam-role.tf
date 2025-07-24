module "role_task_execution" {
  count  = local.create_ecs || local.create_batch ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "task-execution"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["ecs-tasks"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess",
  ]

  inline_policies = [
    {
      name   = "SecretsManagerReadOnly"
      policy = data.aws_iam_policy_document.secrets_manager_read_only.json
    }
  ]
}

module "role_task" {
  count  = local.create_ecs || local.create_batch ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "task"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["ecs-tasks"].json

  inline_policies = [
    {
      name   = "S3ReadWrite"
      policy = data.aws_iam_policy_document.s3_read_write.json
    }
  ]
}

module "role_batch" {
  count  = local.create_batch ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "batch"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["batch"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole",
  ]
}

module "role_batch_scheduler" {
  count  = local.create_batch ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "batch-scheduler"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["scheduler"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceEventTargetRole",
  ]
}

module "role_codepipeline" {
  count  = var.create_codepipeline ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "codepipeline"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["codepipeline"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess",
  ]

  inline_policies = [
    {
      name   = "SecretsManagerReadOnly"
      policy = data.aws_iam_policy_document.secrets_manager_read_only.json
    },
    {
      name   = "S3ReadWrite"
      policy = data.aws_iam_policy_document.s3_read_write.json
    },
    {
      name   = "CodeConnections"
      policy = data.aws_iam_policy_document.codeconnections.json
    },
    {
      name   = "CodePipeline"
      policy = data.aws_iam_policy_document.codepipeline.json
    },
  ]
}

module "role_codebuild" {
  count  = var.create_codepipeline ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "codebuild"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["codebuild"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess",
  ]

  inline_policies = [
    {
      name   = "SecretsManagerReadOnly"
      policy = data.aws_iam_policy_document.secrets_manager_read_only.json
    },
    {
      name   = "S3ReadWrite"
      policy = data.aws_iam_policy_document.s3_read_write.json
    },
    {
      name   = "CodeConnections"
      policy = data.aws_iam_policy_document.codeconnections.json
    },
    {
      name   = "CodeBuild"
      policy = data.aws_iam_policy_document.codebuild.json
    },
  ]
}

module "role_codedeploy" {
  count  = var.create_codepipeline ? 1 : 0
  source = "../modules/iam/role"

  workspace = local.workspace

  name = "codedeploy"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["codedeploy"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS",
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda",
  ]
}