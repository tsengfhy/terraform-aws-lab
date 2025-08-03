locals {
  trusted_services = [
    "ecs-tasks",
    "batch",
    "scheduler",
    "codepipeline",
    "codebuild",
    "codedeploy",
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

data "aws_iam_policy_document" "secrets_manager_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.region}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging",
      "s3:GetObjectVersionTagging",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
    ]
    resources = ["arn:aws:s3:::*/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    resources = ["arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.current.region}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codeconnections" {
  statement {
    effect = "Allow"
    actions = [
      "codeconnections:UseConnection",
      "codestar-connections:UseConnection",
    ]
    resources = [
      "arn:aws:codeconnections:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:connection/*",
    ]
  }
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
    ]
    resources = [
      "arn:aws:codebuild:*:${data.aws_caller_identity.current.account_id}:project/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = [
      "arn:aws:codedeploy:*:${data.aws_caller_identity.current.account_id}:application:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentGroup",
      "codedeploy:GetDeployment",
      "codedeploy:CreateDeployment",
    ]
    resources = [
      "arn:aws:codedeploy:*:${data.aws_caller_identity.current.account_id}:deploymentgroup:*/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentConfig",
    ]
    resources = [
      "arn:aws:codedeploy:*:${data.aws_caller_identity.current.account_id}:deploymentconfig:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
    ]
    resources = [
      "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:task-definition/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:List*",
      "ecs:Describe*",
    ]
    resources = ["*"]
  }
}