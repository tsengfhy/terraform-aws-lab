locals {
  global_prefix = "default-${data.aws_caller_identity.this.account_id}"
  prefix        = "${var.environment}-${data.aws_caller_identity.this.account_id}"

  tags = {
    Environment = var.environment
    Owner       = data.aws_caller_identity.this.account_id
  }
}