output "id" {
  value = aws_lambda_function.this.id
}

output "arn" {
  value = aws_lambda_function.this.arn
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "dlq_id" {
  value = var.use_dlq ? one(module.dlq).id : null
}

output "dlq_arn" {
  value = var.use_dlq ? one(module.dlq).arn : null
}