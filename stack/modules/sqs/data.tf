locals {
  queues = {
    for key, value in var.queues : key => defaults(value, {
      enable_fifo                = false
      delay_seconds              = 0
      visibility_timeout_seconds = 300
      message_retention_seconds  = 345600
      enable_dlq                 = true
      max_receive_count          = 1
    })
  }
}

data "aws_kms_key" "sqs" {
  key_id = var.sqs_kms_key_id
}