module "waf" {
  count  = var.create_waf ? 1 : 0
  source = "../modules/waf"

  workspace = local.workspace

  rate_based_rules = [
    {
      name     = "rate-limiting-by-ip"
      priority = 10
      statement = {
        limit = 20
      }
      action = {
        type = "BLOCK"
      }
    }
  ]

  managed_rule_groups = [
    {
      name     = "aws-common"
      priority = 100
      statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
  ]
}

resource "aws_wafv2_web_acl_association" "apigateway" {
  for_each = var.create_waf ? var.apis : {}

  web_acl_arn  = one(module.waf).arn
  resource_arn = module.stage[each.key].arn
}