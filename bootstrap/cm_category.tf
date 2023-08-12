resource "aws_ce_cost_category" "workspace" {
  name          = "${local.workspace}-cost-category-workspace"
  rule_version  = "CostCategoryExpression.v1"
  default_value = "shared"

  dynamic "rule" {
    for_each = var.workspaces

    content {
      type  = "REGULAR"
      value = rule.value

      rule {
        tags {
          key           = var.workspace_tag_key
          match_options = ["EQUALS"]
          values        = [rule.value]
        }
      }
    }
  }

  rule {
    type  = "REGULAR"
    value = "shared"

    rule {
      tags {
        key           = var.workspace_tag_key
        match_options = ["EQUALS"]
        values        = [local.workspace]
      }
    }
  }
}
