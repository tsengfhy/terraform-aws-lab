resource "aws_s3_bucket" "log" {
  count = var.create_log_bucket ? 1 : 0

  bucket        = "${local.workspace}-${data.aws_caller_identity.current.account_id}-log"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  count = var.create_log_bucket ? 1 : 0

  bucket = one(aws_s3_bucket.log).id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log" {
  count = var.create_log_bucket ? 1 : 0

  bucket = one(aws_s3_bucket.log).id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "log" {
  count = var.create_log_bucket ? 1 : 0

  bucket = one(aws_s3_bucket.log).id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "log" {
  count = var.create_log_bucket ? 1 : 0

  bucket = one(aws_s3_bucket.log).id
  policy = one(data.aws_iam_policy_document.log).json
}

data "aws_iam_policy_document" "log" {
  count = var.create_log_bucket ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
    ]
    resources = [
      one(aws_s3_bucket.log).arn,
      "${one(aws_s3_bucket.log).arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = formatlist("%s.amazonaws.com", var.log_bucket_support_services)
    }
  }

  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      one(aws_s3_bucket.log).arn,
      "${one(aws_s3_bucket.log).arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log" {
  count = var.create_log_bucket ? 1 : 0

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
