module "context" {
  source = "../context"

  environment = var.environment
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = var.default_root_object
  price_class         = "PriceClass_All"
  wait_for_deployment = true

  origin {
    origin_id   = "default"
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "default"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    default_ttl            = 86400
    min_ttl                = 86400
    max_ttl                = 86400

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = false
    }
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
    response_page_path    = "/"
    response_code         = 200
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.acm_certificate_arn == null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "logging_config" {
    for_each = var.log_bucket_name != null ? [0] : []
    content {
      bucket          = one(data.aws_s3_bucket.log).bucket_domain_name
      prefix          = "${module.context.prefix}-cloudfront/"
      include_cookies = true
    }
  }

  tags = module.context.tags
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${module.context.prefix}-oai"
}

