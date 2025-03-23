module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_ecs_service" "this" {
  name                   = "${module.context.prefix}-ecs-service-${var.name}"
  launch_type            = "FARGATE"
  cluster                = data.aws_ecs_cluster.selected.arn
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  force_new_deployment   = true
  enable_execute_command = false

  health_check_grace_period_seconds = var.use_lb ? var.health_check_grace_period_seconds : null

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = [for key, value in data.aws_subnet.selected : value.id]
    security_groups = concat([aws_security_group.this.id], var.security_group_ids)
  }

  dynamic "load_balancer" {
    for_each = var.use_lb ? [0] : []

    content {
      target_group_arn = one(aws_lb_target_group.this).arn
      container_name   = local.default_container_name
      container_port   = var.container_port
    }
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = module.context.tags

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${module.context.prefix}-ecs-task-${var.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.task_execution.arn
  task_role_arn            = data.aws_iam_role.task.arn
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name        = local.default_container_name
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
        command  = ["CMD-SHELL", "curl -f http://localhost${var.health_check} || exit 1"]
        interval = 30
        retries  = 3
        timeout  = 5
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = data.aws_region.current.name
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-stream-prefix = local.service
        }
      }
    }
  ])

  tags = module.context.tags
}