resource "aws_ce_anomaly_monitor" "service" {
  name              = "${module.context.prefix}-anomaly-monitor-service"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"

  tags = module.context.tags
}

resource "aws_ce_anomaly_monitor" "workspace" {
  for_each = toset(var.workspaces)

  name         = "${module.context.prefix}-anomaly-monitor-workspace-${each.key}"
  monitor_type = "CUSTOM"

  monitor_specification = jsonencode({
    And = null
    Or  = null
    Not = null
    CostCategories = {
      Key          = aws_ce_cost_category.workspace.name
      MatchOptions = null
      Values       = [each.key]
    }
    Dimensions = null
    Tags       = null
  })

  tags = module.context.tags
}

resource "aws_ce_anomaly_subscription" "daily" {
  count = length(var.notification_email_addresses) > 0 ? 1 : 0

  name      = "${module.context.prefix}-anomaly-subscription-daily"
  frequency = "DAILY"

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [var.cost_anomaly_amount]
    }
  }

  monitor_arn_list = flatten([
    [aws_ce_anomaly_monitor.service.arn],
    [for item in var.workspaces : aws_ce_anomaly_monitor.workspace[item].arn]
  ])

  dynamic "subscriber" {
    for_each = var.notification_email_addresses

    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }

  tags = module.context.tags
}
