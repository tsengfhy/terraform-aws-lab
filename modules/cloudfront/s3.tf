module "s3" {
  source = "../s3"

  workspace = var.workspace

  name             = "cloudfront-orgin-${var.name}"
  force_destroy    = true
  use_versioning   = true
  use_kms          = false
  policy_documents = [data.aws_iam_policy_document.s3.json]
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

data "aws_s3_bucket" "this" {
  bucket = module.s3.id
}