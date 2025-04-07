module "role" {
  source = "../iam/role"

  workspace = var.workspace

  name = "lambda-${var.name}"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume.json

  managed_policy_arns = concat(
    [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    ],
    local.use_vpc ? [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
    ] : [],
    var.use_xray ? [
      "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
    ] : [],
    var.managed_policy_arns
  )

  inline_policies = concat(
    var.use_dlq ? [
      {
        name   = "DLQWriteOnly"
        policy = one(data.aws_iam_policy_document.sqs).json
      }
    ] : [],
    var.inline_policies
  )
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sqs" {
  count = var.use_dlq ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    resources = [
      one(module.dlq).arn
    ]
  }
}