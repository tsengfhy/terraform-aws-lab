module "batch" {
  count  = local.create_batch ? 1 : 0
  source = "../modules/batch"

  workspace = local.workspace

  capacity_provider       = "FARGATE_SPOT"
  subnet_ids              = module.vpc.private_subnets
  batch_service_role_name = split("/", one(aws_iam_role.batch_service).arn)[1]
}

module "job" {
  for_each = var.jobs
  source   = "../modules/batch/job"

  workspace = local.workspace

  name                              = each.key
  task_execution_role_name          = split("/", one(aws_iam_role.task_execution).arn)[1]
  task_role_name                    = split("/", one(aws_iam_role.task).arn)[1]
  ecr_name                          = split("/", module.ecr["batch"].arn)[1]
  timezone                          = "Asia/Shanghai"
  schedule_expression               = each.value.schedule_expression
  batch_service_scheduler_role_name = split("/", one(aws_iam_role.batch_service_scheduler).arn)[1]
  batch_job_queue_name              = split("/", one(module.batch).batch_job_queue_arn)[1]

  envs = [
    {
      name  = "JOB_NAME"
      value = each.key
    }
  ]

  secrets = [for item in lookup(local.secrets["default"], "secret_keys") : {
    name      = item,
    valueFrom = "${module.secretsmanager["default"].arn}:${item}::"
  }]
}