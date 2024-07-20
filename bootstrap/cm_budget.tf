resource "aws_budgets_budget" "cost_monthly" {
  name         = "${module.context.prefix}-budget-cost-monthly"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_unit   = "USD"
  limit_amount = var.cost_limit_amount

  dynamic "notification" {
    for_each = length(var.notification_email_addresses) > 0 ? [0] : []

    content {
      comparison_operator        = "GREATER_THAN"
      threshold_type             = "PERCENTAGE"
      threshold                  = "90"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.notification_email_addresses
    }
  }

  tags = module.context.tags
}

resource "aws_budgets_budget" "usage_bandwidth" {
  name         = "${module.context.prefix}-budget-usage-bandwidth"
  budget_type  = "USAGE"
  time_unit    = "MONTHLY"
  limit_unit   = "GB"
  limit_amount = "100"

  cost_filter {
    name = "UsageType"
    values = [
      "${join("", [for item in split("-", data.aws_region.current.name) : upper(substr(item, 0, length(item) == 2 ? 2 : 1))])}-DataTransfer-Out-Bytes",
    ]
  }

  dynamic "notification" {
    for_each = length(var.notification_email_addresses) > 0 ? [0] : []

    content {
      comparison_operator        = "GREATER_THAN"
      threshold_type             = "PERCENTAGE"
      threshold                  = "90"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.notification_email_addresses
    }
  }

  tags = module.context.tags
}
