resource "aws_cloudwatch_log_group" "this" {
  count = var.use_logging ? 1 : 0

  name              = "aws-waf-logs-${local.name}"
  retention_in_days = var.logging_config.retention_in_days
  kms_key_id        = try(one(data.aws_kms_alias.log).target_key_arn, null)
  skip_destroy      = var.logging_config.skip_destroy

  tags = module.context.tags
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  count = var.use_logging ? 1 : 0

  policy_name     = "aws-waf-logs-${local.name}"
  policy_document = one(data.aws_iam_policy_document.log_group).json
}

data "aws_iam_policy_document" "log_group" {
  count = var.use_logging ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${one(aws_cloudwatch_log_group.this).arn}:log-stream:*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}