module "vpc" {
  source = "./modules/vpc"

  environment = local.environment
}

module "cloudfront" {
  count  = var.create_cloudfront ? 1 : 0
  source = "./modules/cloudfront"

  environment     = local.environment
  log_bucket_name = local.lob_bucket_name
}