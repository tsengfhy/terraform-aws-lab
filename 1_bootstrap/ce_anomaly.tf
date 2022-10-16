resource "aws_ce_anomaly_monitor" "service" {
  name              = "${local.prefix}anomaly-monitor-service"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_monitor" "workspace" {
  for_each     = toset(var.workspaces)
  name         = "${local.prefix}anomaly-monitor-workspace-${each.key}"
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
}

resource "aws_ce_anomaly_subscription" "daily" {
  count     = length(var.notification_email_addresses) > 0 ? 1 : 0
  name      = "${local.prefix}anomaly-subscription-daily"
  frequency = "DAILY"
  threshold = var.cost_anomaly_amont

  monitor_arn_list = flatten([
    [aws_ce_anomaly_monitor.service.arn],
    [for workspace in var.workspaces : aws_ce_anomaly_monitor.workspace[workspace].arn]
  ])

  dynamic "subscriber" {
    for_each = var.notification_email_addresses

    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }
}
