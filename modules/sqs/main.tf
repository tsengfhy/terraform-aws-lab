module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_sqs_queue" "this" {
  depends_on = [data.aws_kms_alias.selected]

  name              = "${module.context.prefix}-queue-${var.name}${local.suffix}"
  kms_master_key_id = var.use_kms ? one(data.aws_kms_alias.selected).name : null

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  fifo_queue                  = var.use_fifo
  content_based_deduplication = var.use_fifo

  tags = module.context.tags
}

resource "aws_sqs_queue_redrive_policy" "this" {
  count = var.use_dlq ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = one(aws_sqs_queue.dlq).arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "dlq" {
  depends_on = [data.aws_kms_alias.selected]
  count      = var.use_dlq ? 1 : 0

  name              = "${module.context.prefix}-queue-${var.name}-dlq${local.suffix}"
  kms_master_key_id = var.use_kms ? one(data.aws_kms_alias.selected).name : null

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = 1209600
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  fifo_queue                  = var.use_fifo
  content_based_deduplication = var.use_fifo

  tags = module.context.tags
}



