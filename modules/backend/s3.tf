resource "aws_s3_bucket" "backend" {
  bucket        = "${module.context.prefix}-terraform-backend"
  force_destroy = true

  tags = module.context.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "backend" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.backend.id

  target_bucket = one(aws_s3_bucket.log).id
  target_prefix = "terraform-backend/"
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "backend" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.backend.json
}

data "aws_iam_policy_document" "backend" {
  statement {
    sid       = "Require encrypted transport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${module.context.prefix}-terraform-backend/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}