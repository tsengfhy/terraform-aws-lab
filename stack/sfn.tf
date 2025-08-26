module "sfn" {
  for_each = var.state_machines
  source   = "../modules/sfn"

  workspace = local.workspace

  name = each.key

  definition = templatefile("${path.module}/tests/sfn/${each.key}.json", merge(
    each.value.use_notification ? {
      notificationArn = module.sns.arn
    } : {}
  ))

  inline_policies = concat(
    each.value.use_notification ? [
      {
        name   = "SNSWriteOnly"
        policy = data.aws_iam_policy_document.sns_write_only.json
      }
    ] : []
  )

  logging_config = {
    include_execution_data = true
  }
}