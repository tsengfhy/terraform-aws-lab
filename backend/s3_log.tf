resource "aws_s3_bucket" "log" {
  count         = var.create_log_bucket ? 1 : 0
  bucket        = "${local.workspace}-${data.aws_caller_identity.current.account_id}-logs"
  force_destroy = true

  lifecycle {
    ignore_changes = [grant]
  }
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
    sid     = "Allow write log"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.log[0].arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
  }

  statement {
    sid     = "Require encrypted transport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.log[0].arn,
      "${aws_s3_bucket.log[0].arn}/*"
    ]

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