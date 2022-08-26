resource "local_file" "backend_config" {
  filename        = "${path.module}/${var.backend_config_filename}"
  file_permission = "0644"

  content = templatefile("${path.module}/resources/backend-config.tfvars.tpl", {
    region         = data.aws_region.current.name,
    bucket         = aws_s3_bucket.backend.bucket,
    dynamodb_table = aws_dynamodb_table.lock.name
  })
}