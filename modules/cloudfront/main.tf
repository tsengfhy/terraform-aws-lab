module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_cloudfront_distribution" "this" {
  comment             = "${module.context.prefix}-cloudfront-${var.name}"
  price_class         = "PriceClass_200"
  default_root_object = var.default_root_object
  aliases             = var.use_dns ? ["${var.alias}.${var.domain}"] : null
  web_acl_id          = var.web_acl_id
  is_ipv6_enabled     = var.use_ipv6
  enabled             = var.enabled
  wait_for_deployment = true

  origin {
    origin_id                = local.primary_origin_id
    domain_name              = data.aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = local.primary_origin_id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.selected.id
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
    response_page_path    = "/"
    response_code         = 200
  }

  viewer_certificate {
    cloudfront_default_certificate = !var.use_dns
    acm_certificate_arn            = var.use_dns ? one(data.aws_acm_certificate.selected).arn : null
    ssl_support_method             = var.use_dns ? "sni-only" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "logging_config" {
    for_each = var.use_logging ? [0] : []

    content {
      bucket = one(data.aws_s3_bucket.log).bucket_domain_name
      prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/CloudFront/${module.context.prefix}-cloudfront-${var.name}/"
    }
  }

  tags = module.context.tags

  lifecycle {
    ignore_changes = [enabled]
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${module.context.prefix}-cloudfront-oac-${var.name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "selected" {
  name = var.use_caching ? "Managed-CachingOptimized" : "Managed-CachingDisabled"
}

