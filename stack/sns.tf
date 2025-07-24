module "sns" {
  source = "../modules/sns"

  workspace = local.workspace

  name = "notification"

  use_kms = false
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
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    principals {
      type = "Service"
      identifiers = [
        "codestar-notifications.amazonaws.com",
      ]
    }
  }
}

resource "aws_sns_topic_subscription" "this" {
  for_each = toset(var.notification_email_addresses)

  topic_arn = module.sns.arn
  protocol  = "email"
  endpoint  = each.value
}