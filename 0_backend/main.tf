module "context" {
  source = "../9_stack/modules/context"

  environment = local.environment
}

resource "local_file" "backend_config" {
  count    = var.backend_config_filename != null ? 1 : 0
  filename = var.backend_config_filename
  content = templatefile("${path.module}/resources/backend-config.tfvars.tpl", {
    region         = data.aws_region.current.name,
    bucket         = aws_s3_bucket.backend.bucket,
    dynamodb_table = try(one(aws_dynamodb_table.lock).name, "")
  })
}