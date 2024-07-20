module "cloudfront" {
  for_each = var.pages
  source   = "../modules/cloudfront"

  workspace = local.workspace

  name            = each.key
  use_caching     = false
  use_dns         = each.value.alias != null && var.domain != null
  domain          = var.domain
  alias           = each.value.alias
  use_logging     = true
  log_bucket_name = data.aws_s3_bucket.log.bucket
  enabled         = true

  providers = {
    aws.global = aws.global
  }
}

resource "aws_s3_object" "cloudfront" {
  for_each = var.pages

  bucket       = split(":", module.cloudfront[each.key].s3.arn)[5]
  key          = module.cloudfront[each.key].default_root_object
  source       = "./tests/cloudfront/index.html"
  content_type = "text/html"
}