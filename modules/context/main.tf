locals {
  prefix               = var.workspace
  global_prefix        = "global"
  unique_prefix        = "${local.prefix}-${data.aws_caller_identity.current.account_id}"
  global_unique_prefix = "${local.global_prefix}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Workspace = var.workspace
    Owner     = data.aws_caller_identity.current.account_id
  }
}
