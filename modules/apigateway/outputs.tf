output "id" {
  value = aws_api_gateway_rest_api.this.id
}

output "arn" {
  value = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

output "root_resource_id" {
  value = var.body == null ? aws_api_gateway_rest_api.this.root_resource_id : null
}

output "body" {
  value = aws_api_gateway_rest_api.this.body
}