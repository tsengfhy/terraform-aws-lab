module "role" {
  source = "../iam/role"

  workspace = var.workspace

  name = "sfn-${var.name}"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume.json

  managed_policy_arns = concat(
    var.use_xray ? [
      "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
    ] : [],
    var.managed_policy_arns
  )

  inline_policies = concat(
    [
      {
        name   = "Logging"
        policy = data.aws_iam_policy_document.logging.json
      }
    ],
    var.inline_policies
  )
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:ListLogDeliveries",
      "logs:*LogDelivery",
      "logs:DescribeResourcePolicies",
      "logs:PutResourcePolicy",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}