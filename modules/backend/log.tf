resource "aws_s3_bucket" "log" {
  count         = var.create_log_bucket ? 1 : 0
  bucket        = "${module.context.prefix}-logs"
  force_destroy = true

  tags = module.context.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = one(aws_s3_bucket.log).id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = one(aws_s3_bucket.log).id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "log" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = one(aws_s3_bucket.log).id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "log" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = one(aws_s3_bucket.log).id
  policy = one(data.aws_iam_policy_document.log).json
}

data "aws_iam_policy_document" "log" {
  count = var.create_log_bucket ? 1 : 0

  statement {
    sid       = "Require encrypted transport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${module.context.prefix}-logs/*"]
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

resource "aws_s3_bucket_lifecycle_configuration" "log" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = one(aws_s3_bucket.log).id

  rule {
    id     = "Log Bucket Lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 180
    }
  }
}