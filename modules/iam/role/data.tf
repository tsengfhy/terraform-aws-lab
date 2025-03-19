data "aws_iam_policy" "selected" {
  for_each = var.managed_policy_arns

  arn = each.value
}