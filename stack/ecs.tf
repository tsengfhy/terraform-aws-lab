module "alb" {
  count  = local.create_ecs ? 1 : 0
  source = "../modules/elb"

  workspace = local.workspace

  subnet_ids      = module.vpc.public_subnets
  use_dns         = var.domain != null
  domain          = var.domain
  alias           = "service"
  forwarded_ports = [for item in var.services : item.container_port]
}

module "ecs" {
  count  = local.create_ecs ? 1 : 0
  source = "../modules/ecs"

  workspace = local.workspace

  capacity_provider = "FARGATE_SPOT"
}

module "service" {
  for_each = var.services
  source   = "../modules/ecs/service"

  workspace = local.workspace

  name                     = each.key
  ecs_cluster_arn          = one(module.ecs).arn
  subnet_ids               = module.vpc.private_subnets
  task_execution_role_name = one(module.role_task_execution).id
  task_role_name           = one(module.role_task).id
  ecr_name                 = module.ecr["ecs"].id
  container_port           = each.value.container_port
  health_check             = each.value.health_check
  use_lb                   = true
  listener_arn             = one(module.alb).listener_arn
  priority                 = each.value.priority
  path_pattern             = each.value.path_pattern
  stickiness               = each.value.stickiness

  envs = [
    {
      name  = "ENVIRONMENT"
      value = local.workspace
    }
  ]

  secrets = [for item in lookup(local.secrets["default"], "secret_keys") : {
    name      = item,
    valueFrom = "${module.secretsmanager["default"].arn}:${item}::"
  }]
}