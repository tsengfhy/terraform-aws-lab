locals {
  trusted_services = [
    "ecs-tasks",
    "batch",
    "scheduler",
  ]
}

data "aws_iam_policy_document" "assume" {
  for_each = { for item in local.trusted_services : item => {} }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["${each.key}.amazonaws.com"]
    }
  }
}

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

data "aws_iam_policy_document" "secrets_manager_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
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

data "aws_iam_policy_document" "s3_read_write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*Object",
    ]
    resources = ["arn:aws:s3:::*/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

module "role_batch_service" {
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

module "role_batch_service_scheduler" {
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