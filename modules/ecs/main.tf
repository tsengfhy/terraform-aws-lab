module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_ecs_cluster" "this" {
  name = "${module.context.prefix}-ecs-${var.name}"

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }

  tags = module.context.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [var.capacity_provider]
}