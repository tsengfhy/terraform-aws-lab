module "log" {
  source = "../modules/s3"

  workspace = local.workspace

  name                     = "log"
  force_destroy            = true
  object_ownership         = "BucketOwnerPreferred"
  use_versioning           = false
  use_kms                  = false
  policy_documents         = [data.aws_iam_policy_document.log.json]
  use_transition_lifecycle = true
  use_expiration_lifecycle = true
}

data "aws_iam_policy_document" "log" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
    ]
    resources = [
      module.log.arn,
      "${module.log.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = formatlist("%s.amazonaws.com", var.log_bucket_supported_services)
    }
  }
}

data "aws_s3_bucket" "selected" {
  for_each = var.log_bucket_supported_buckets

  bucket = "${module.context.unique_prefix}-${each.key}"
}

resource "aws_s3_bucket_logging" "backend" {
  for_each = var.log_bucket_supported_buckets

  bucket = data.aws_s3_bucket.selected[each.key].id

  target_bucket = module.log.id
  target_prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/S3/${data.aws_s3_bucket.selected[each.key].id}/"
}
