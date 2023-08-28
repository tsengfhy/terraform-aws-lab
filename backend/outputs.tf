output "region" {
  value = data.aws_region.current.name
}

output "bucket" {
  value = aws_s3_bucket.backend.bucket
}

output "dynamodb_table" {
  value = aws_dynamodb_table.lock.name
}