module "context" {
  source = "../context"

  environment = var.environment
}

resource "aws_sqs_queue" "this" {
  for_each          = local.queues
  name              = "${module.context.prefix}-queue-${each.key}"
  kms_master_key_id = data.aws_kms_key.sqs.arn

  delay_seconds              = each.value.delay_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = each.value.message_retention_seconds

  fifo_queue                  = each.value.enable_fifo
  content_based_deduplication = each.value.enable_fifo

  redrive_policy = each.value.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  }) : null

  tags = module.context.tags
}

resource "aws_sqs_queue" "dlq" {
  for_each          = { for key, value in local.queues : key => value if value.enable_dlq }
  name              = "${module.context.prefix}-queue-${each.key}-dlq"
  kms_master_key_id = data.aws_kms_key.sqs.arn

  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = 1209600

  fifo_queue                  = each.value.enable_fifo
  content_based_deduplication = each.value.enable_fifo

  tags = module.context.tags
}



