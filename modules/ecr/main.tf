module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_ecr_repository" "this" {
  name                 = "${module.context.prefix}-repository-${var.name}"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_destroy

  encryption_configuration {
    encryption_type = var.use_kms ? "KMS" : "AES256"
    kms_key         = var.use_kms ? one(data.aws_kms_alias.selected).target_key_arn : null
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = module.context.tags
}