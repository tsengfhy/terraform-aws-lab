module "backend" {
  source = "../modules/s3"

  workspace = local.workspace

  name           = "terraform-backend"
  force_destroy  = false
  use_versioning = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backend" {
  bucket = module.backend.id

  rule {
    id     = "backend"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = 2
      noncurrent_days           = 30
    }
  }
}

resource "local_file" "backend_config" {
  filename        = "${path.module}/${var.backend_config_filename}"
  file_permission = "0644"

  content = templatefile("${path.module}/resources/backend-config.tfvars.tpl", {
    region = data.aws_region.current.region
    bucket = module.backend.id
  })
}