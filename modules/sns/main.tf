module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_sns_topic" "this" {
  depends_on = [data.aws_kms_alias.selected]

  name              = "${module.context.prefix}-sns-${var.name}${local.suffix}"
  kms_master_key_id = var.use_kms ? one(data.aws_kms_alias.selected).name : null

  fifo_topic                  = var.use_fifo
  content_based_deduplication = var.use_fifo

  tags = module.context.tags
}