module "ses" {
  count  = var.domain != null ? 1 : 0
  source = "../modules/ses"

  workspace = local.workspace

  domain          = var.domain
  mail_from_alias = "mail"
  use_dns         = true
}