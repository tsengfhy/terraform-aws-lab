module "dlq" {
  count  = var.use_dlq ? 1 : 0
  source = "../sqs"

  workspace = var.workspace

  name      = "lambda-function-${var.name}-dlq"
  kms_alias = var.dlq_kms_alias
  use_dlq   = false
}