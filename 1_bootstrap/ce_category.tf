resource "aws_ce_cost_allocation_tag" "workspace" {
  tag_key = var.worksapce_tag_key
  status  = "Active"
}

resource "aws_ce_cost_category" "workspace" {
  name          = "${local.prefix}category-workspace"
  rule_version  = "CostCategoryExpression.v1"
  default_value = "shared"

  dynamic "rule" {
    for_each = var.workspaces

    content {
      type  = "REGULAR"
      value = rule.value

      rule {
        tags {
          key           = aws_ce_cost_allocation_tag.workspace.id
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
        key           = aws_ce_cost_allocation_tag.workspace.id
        match_options = ["EQUALS"]
        values        = [local.workspace]
      }
    }
  }
}
