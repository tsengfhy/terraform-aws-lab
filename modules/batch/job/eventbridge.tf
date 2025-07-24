resource "aws_scheduler_schedule" "this" {
  name                         = "${module.context.prefix}-scheduler-batch-${var.name}"
  schedule_expression_timezone = var.timezone
  schedule_expression          = var.schedule_expression
  state                        = var.enabled ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:batch:submitJob"
    role_arn = data.aws_iam_role.scheduler.arn

    input = jsonencode({
      JobQueue      = data.aws_batch_job_queue.selected.arn
      JobName       = var.name
      JobDefinition = aws_batch_job_definition.this.arn
    })

    retry_policy {
      maximum_retry_attempts = 0
    }
  }

  lifecycle {
    ignore_changes = [state]
  }
}