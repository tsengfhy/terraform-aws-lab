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

resource "aws_iam_role" "task_execution" {
  count = local.create_ecs || local.create_batch ? 1 : 0

  name = "${module.context.prefix}-task-execution"

  assume_role_policy = data.aws_iam_policy_document.assume["ecs-tasks"].json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess",
  ]

  inline_policy {
    name   = "SecretsManagerReadOnly"
    policy = data.aws_iam_policy_document.secrets_manager_read_only.json
  }

  tags = module.context.tags
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

resource "aws_iam_role" "task" {
  count = local.create_ecs || local.create_batch ? 1 : 0

  name = "${module.context.prefix}-task"

  assume_role_policy = data.aws_iam_policy_document.assume["ecs-tasks"].json

  inline_policy {
    name   = "S3ReadWrite"
    policy = data.aws_iam_policy_document.s3_read_write.json
  }

  tags = module.context.tags
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

resource "aws_iam_role" "batch_service" {
  count = local.create_batch ? 1 : 0

  name = "${module.context.prefix}-batch"

  assume_role_policy = data.aws_iam_policy_document.assume["batch"].json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole",
  ]

  tags = module.context.tags
}

resource "aws_iam_role" "batch_service_scheduler" {
  count = local.create_batch ? 1 : 0

  name = "${module.context.prefix}-batch-scheduler"

  assume_role_policy = data.aws_iam_policy_document.assume["scheduler"].json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceEventTargetRole",
  ]

  tags = module.context.tags
}