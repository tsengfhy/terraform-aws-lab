module "sns" {
  source = "../../sns"

  workspace = var.workspace

  name      = "configuration-set-${var.name}"
  use_kms   = var.use_kms
  kms_alias = var.use_kms ? one(data.aws_kms_alias.selected).name : null
  use_fifo  = var.use_fifo
}

resource "aws_sns_topic_policy" "this" {
  arn    = module.sns.arn
  policy = data.aws_iam_policy_document.sns.json
}

data "aws_iam_policy_document" "sns" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [module.sns.arn]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_sesv2_configuration_set.this.arn]
    }
  }
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn            = module.sns.arn
  protocol             = "sqs"
  endpoint             = module.sqs.arn
  raw_message_delivery = true
}