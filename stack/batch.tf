module "batch" {
  count  = local.create_batch ? 1 : 0
  source = "../modules/batch"

  workspace = local.workspace

  capacity_provider = "FARGATE_SPOT"
  subnet_ids        = module.vpc.private_subnets
  service_role_name = one(module.role_batch).id
}

module "job" {
  for_each = var.jobs
  source   = "../modules/batch/job"

  workspace = local.workspace

  name                     = each.key
  task_execution_role_name = one(module.role_task_execution).id
  task_role_name           = one(module.role_task).id
  ecr_name                 = module.ecr["batch"].id
  timezone                 = "Asia/Shanghai"
  schedule_expression      = each.value.schedule_expression
  scheduler_role_name      = one(module.role_batch_scheduler).id
  job_queue_arn            = one(module.batch).batch_job_queue_arn

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