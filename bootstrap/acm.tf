module "acm" {
  count  = var.domain != null ? 1 : 0
  source = "../modules/acm"

  workspace = local.workspace

  domain = var.domain
}

module "acm_global" {
  count  = var.domain != null ? 1 : 0
  source = "../modules/acm"

  workspace = local.workspace

  domain = var.domain

  providers = {
    aws = aws.global
  }
}