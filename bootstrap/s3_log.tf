resource "aws_s3_bucket" "log" {
  bucket        = "${local.workspace}-${data.aws_caller_identity.current.account_id}-log"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "log" {
  bucket = aws_s3_bucket.log.id
  policy = data.aws_iam_policy_document.log.json
}

data "aws_iam_policy_document" "log" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.log.arn,
      "${aws_s3_bucket.log.arn}/*"
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
      aws_s3_bucket.log.arn,
      "${aws_s3_bucket.log.arn}/*"
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
  bucket = aws_s3_bucket.log.id

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

data "aws_s3_bucket" "selected" {
  for_each = toset(var.log_bucket_support_buckets)

  bucket = "${local.workspace}-${data.aws_caller_identity.current.account_id}-${each.key}"
}

resource "aws_s3_bucket_logging" "backend" {
  for_each = toset(var.log_bucket_support_buckets)

  bucket = data.aws_s3_bucket.selected[each.key].id

  target_bucket = aws_s3_bucket.log.id
  target_prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/S3/${data.aws_s3_bucket.selected[each.key].id}/"
}
