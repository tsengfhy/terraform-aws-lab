module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_iam_role" "this" {
  name        = var.is_service_linked ? var.name : "${module.context.prefix}-role-${var.name}"
  path        = var.is_service_linked ? "/service-role/" : var.path
  description = var.description

  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  assume_role_policy    = var.assume_role_policy

  tags = module.context.tags
}

resource "aws_iam_role_policy_attachments_exclusive" "this" {
  depends_on = [data.aws_iam_policy.selected]

  role_name   = aws_iam_role.this.id
  policy_arns = var.managed_policy_arns
}

resource "aws_iam_role_policies_exclusive" "this" {
  depends_on = [aws_iam_role_policy.this]

  role_name    = aws_iam_role.this.id
  policy_names = [for item in var.inline_policies : item.name]
}

resource "aws_iam_role_policy" "this" {
  for_each = { for item in var.inline_policies : item.name => item.policy }

  role   = aws_iam_role.this.id
  name   = each.key
  policy = each.value
}