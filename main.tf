module "vpc" {
  source = "./modules/vpc"

  environment = local.environment
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
  source = "./modules/cloudfront"

  environment     = local.environment
  log_bucket_name = local.lob_bucket_name
}

module "ecs" {
  depends_on = [
    module.vpc,
    aws_iam_role.ecs_task_execution,
    aws_iam_role.ecs_task
  ]

  count  = var.create_ecs ? 1 : 0
  source = "./modules/ecs"

  environment         = local.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_tags  = module.vpc.public_subnet_tags
  private_subnet_tags = module.vpc.private_subnet_tags
  task_execution_role = aws_iam_role.ecs_task_execution.name
  task_role           = aws_iam_role.ecs_task.name
}