module "context" {
  source = "../context"

  environment = var.environment
}

resource "aws_ecs_cluster" "this" {
  name               = "${module.context.prefix}-ecs-cluster"
  capacity_providers = [var.capacity_provider]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = module.context.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${module.context.prefix}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.task_execution_role.arn
  task_role_arn            = data.aws_iam_role.task_role.arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    {
      name      = aws_ecr_repository.this.name
      image     = "${aws_ecr_repository.this.repository_url}:latest"
      essential = true

      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.task_container_port
          hostPort      = var.task_container_port
        }
      ]

      environment = [
        {
          name  = var.task_env_key
          value = var.environment
        }
      ]

      secrets = [
        for key in var.task_secrets : {
          name      = key,
          valueFrom = "${one(aws_secretsmanager_secret.this).arn}:${key}::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-region        = data.aws_region.current.name
          awslogs-group         = "/aws/ecs/${var.environment}/${var.artifact_id}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = module.context.tags
}

resource "aws_ecs_service" "this" {
  name            = "${module.context.prefix}-ecs-service"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.task_desired_count

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  propagate_tags                     = "SERVICE"
  enable_execute_command             = false
  force_new_deployment               = true

  network_configuration {
    subnets         = data.aws_subnet_ids.private.ids
    security_groups = concat([aws_security_group.task.id], var.security_group_ids)
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = aws_ecr_repository.this.name
    container_port   = var.task_container_port
  }

  tags = module.context.tags
}

resource "aws_security_group" "task" {
  name        = "${module.context.prefix}-sg-ecs-task"
  description = "Security group for ECS task"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol    = "tcp"
    from_port   = var.task_container_port
    to_port     = var.task_container_port
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    prefix_list_ids = [data.aws_vpc_endpoint.s3.prefix_list_id]
  }

  tags = module.context.tags
}



