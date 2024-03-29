module "context" {
  source = "modulesontext"

  environment = local.environment
}

module "vpc" {
  source = "modulespc"

  environment              = local.environment
  bastion_instance_profile = aws_iam_instance_profile.ssm_managed_instance.name

  endpoints = local.create_endpoints ? [
    "ecr.api",
    "ecr.dkr",
    "secretsmanager",
    "logs",
    "monitoring"
  ] : []
}

module "cloudfront" {
  count  = var.create_cloudfront ? 1 : 0
  source = "modulesloudfront"

  environment     = local.environment
  log_bucket_name = local.lob_bucket_name
}

module "ecs" {
  depends_on = [
    aws_iam_role.ecs_task_execution,
    aws_iam_role.ecs_task
  ]

  count  = var.create_ecs ? 1 : 0
  source = "modulescs"

  environment         = local.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_tags  = module.vpc.public_subnet_tags
  private_subnet_tags = module.vpc.private_subnet_tags
  task_execution_role = aws_iam_role.ecs_task_execution.name
  task_role           = aws_iam_role.ecs_task.name
}

module "batch" {
  depends_on = [
    aws_iam_role.batch,
    aws_iam_role.event_target_batch,
    aws_iam_role.ecs_task_execution,
    aws_iam_role.ecs_task
  ]

  count  = var.create_batch ? 1 : 0
  source = "modulesatch"

  environment             = local.environment
  vpc_id                  = module.vpc.vpc_id
  private_subnet_tags     = module.vpc.private_subnet_tags
  batch_role              = aws_iam_role.batch.name
  event_target_batch_role = aws_iam_role.event_target_batch.name
  job_execution_role      = aws_iam_role.ecs_task_execution.name
  job_role                = aws_iam_role.ecs_task.name

  jobs = {
    testJob = {}
  }

  job_secrets = [
    "password"
  ]
}