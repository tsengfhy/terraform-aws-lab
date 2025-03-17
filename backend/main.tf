module "backend" {
  source = "../modules/s3"

  workspace = local.workspace

  name           = "terraform-backend"
  force_destroy  = false
  use_versioning = true
}

resource "local_file" "backend_config" {
  filename        = "${path.module}/${var.backend_config_filename}"
  file_permission = "0644"

  content = templatefile("${path.module}/resources/backend-config.tfvars.tpl", {
    region = data.aws_region.current.name
    bucket = module.backend.id
  })
}