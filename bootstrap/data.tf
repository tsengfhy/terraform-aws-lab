locals {
  workspace = terraform.workspace

  trusted_services = [
    "ssm",
    "apigateway",
  ]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

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