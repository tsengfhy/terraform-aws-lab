resource "aws_ecr_repository" "this" {
  name                 = "${module.context.prefix}-${var.artifact_id}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_key.ecr.arn
  }

  tags = module.context.tags
}