module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_ecs_service" "this" {
  name                   = local.name
  launch_type            = "FARGATE"
  cluster                = data.aws_ecs_cluster.selected.arn
  task_definition        = aws_ecs_task_definition.this.arn
  force_new_deployment   = true
  enable_execute_command = var.use_execute_command

  desired_count                     = var.desired_count
  availability_zone_rebalancing     = "ENABLED"
  health_check_grace_period_seconds = var.use_lb ? var.health_check_grace_period_seconds : null

  deployment_controller {
    type = var.use_codedeploy ? "CODE_DEPLOY" : "ECS"
  }

  dynamic "deployment_configuration" {
    for_each = !var.use_codedeploy ? [0] : []

    content {
      strategy             = var.deployment_config.strategy
      bake_time_in_minutes = var.deployment_config.strategy == "BLUE_GREEN" ? var.deployment_config.bake_time_in_minutes : null
    }
  }

  deployment_minimum_healthy_percent = !var.use_codedeploy && var.deployment_config.strategy == "ROLLING" ? var.deployment_config.minimum_healthy_percent : null
  deployment_maximum_percent         = !var.use_codedeploy && var.deployment_config.strategy == "ROLLING" ? var.deployment_config.maximum_percent : null

  dynamic "deployment_circuit_breaker" {
    for_each = !var.use_codedeploy ? [0] : []

    content {
      enable   = var.deployment_circuit_breaker.enable
      rollback = var.deployment_circuit_breaker.rollback
    }
  }

  network_configuration {
    subnets         = [for key, value in data.aws_subnet.selected : value.id]
    security_groups = concat([aws_security_group.this.id], var.security_group_ids)
  }

  dynamic "load_balancer" {
    for_each = var.use_lb ? [0] : []

    content {
      target_group_arn = aws_lb_target_group.this["blue"].arn
      container_name   = local.primary_container_name
      container_port   = var.container_port
    }
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = module.context.tags

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer,
    ]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${module.context.prefix}-ecs-task-${var.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = data.aws_iam_role.task_execution.arn
  task_role_arn            = data.aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name        = local.primary_container_name
      image       = "${data.aws_ecr_repository.selected.repository_url}:${var.ecr_image_tag}"
      environment = var.envs
      secrets     = var.secrets
      essential   = true

      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]

      healthCheck = {
        command  = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check} || exit 1"]
        interval = 30
        retries  = 3
        timeout  = 5
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = data.aws_region.current.region
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-stream-prefix = local.service
        }
      }
    }
  ])

  tags = module.context.tags
}