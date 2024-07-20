output "arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "default_root_object" {
  value = var.default_root_object
}

output "s3" {
  value = module.s3
}