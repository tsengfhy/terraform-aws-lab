module "sqs" {
  source = "../../sqs"

  workspace = var.workspace

  name      = "configuration-set-${var.name}"
  use_kms   = var.use_kms
  kms_alias = var.use_kms ? one(data.aws_kms_alias.selected).name : null
  use_fifo  = var.use_fifo

  max_receive_count = 3
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = module.sqs.id
  policy    = data.aws_iam_policy_document.sqs.json
}

data "aws_iam_policy_document" "sqs" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [module.sqs.arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.sns.arn]
    }
  }
}