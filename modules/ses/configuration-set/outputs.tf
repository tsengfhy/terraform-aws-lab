output "arn" {
  value = aws_sesv2_configuration_set.this.arn
}

output "sns" {
  value = module.sns
}

output "sqs" {
  value = module.sqs
}