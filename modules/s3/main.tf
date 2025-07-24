module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_s3_bucket" "this" {
  bucket        = "${module.context.unique_prefix}-${var.name}"
  force_destroy = var.force_destroy

  tags = module.context.tags
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.use_versioning ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  depends_on = [data.aws_kms_alias.selected]

  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.use_kms ? one(data.aws_kms_alias.selected).name : null
    }

    bucket_key_enabled = var.use_kms ? true : false
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = var.use_logging ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = one(data.aws_s3_bucket.log).id
  target_prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/S3/${aws_s3_bucket.this.id}/"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
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

  source_policy_documents = var.policy_documents
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.use_default_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "primary"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      storage_class = "STANDARD_IA"
      days          = 30
    }

    expiration {
      days = 180
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.use_versioning ? [0] : []

      content {
        noncurrent_days = 30
      }
    }
  }
}