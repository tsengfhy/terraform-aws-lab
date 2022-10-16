resource "aws_budgets_budget" "monthly_cost" {
  name         = "${local.prefix}budget-monthly-cost"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_unit   = "USD"
  limit_amount = var.cost_limit_amont

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
}