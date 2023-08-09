resource "aws_cloudwatch_event_rule" "this" {
  for_each            = var.jobs
  name                = "${module.context.prefix}-batch-event-${each.key}"
  schedule_expression = "cron(0 0 * * ? *)"
  is_enabled          = false

  lifecycle {
    ignore_changes = [
      schedule_expression,
      is_enabled
    ]
  }

  tags = module.context.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = var.jobs
  rule     = aws_cloudwatch_event_rule.this[each.key].name
  arn      = aws_batch_job_queue.this.arn
  role_arn = data.aws_iam_role.event_target_batch_role.arn

  batch_target {
    job_name       = each.key
    job_definition = aws_batch_job_definition.this[each.key].id
  }
}