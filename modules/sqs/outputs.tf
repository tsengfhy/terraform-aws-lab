output "id" {
  value = aws_sqs_queue.this.id
}

output "arn" {
  value = aws_sqs_queue.this.arn
}

output "dlq_id" {
  value = var.use_dlq ? one(aws_sqs_queue.dlq).id : null
}

output "dlq_arn" {
  value = var.use_dlq ? one(aws_sqs_queue.dlq).arn : null
}