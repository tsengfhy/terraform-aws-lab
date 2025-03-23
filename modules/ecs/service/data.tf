locals {
  service                = "ecs"
  default_container_name = "default"

  vpc_ids = [for key, value in data.aws_subnet.selected : value.vpc_id]
}

data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = element(local.vpc_ids, 0)

  lifecycle {
    precondition {
      condition     = length(toset(local.vpc_ids)) == 1
      error_message = "The subnet ids are not for the same VPC"
    }
  }
}

data "aws_subnet" "selected" {
  for_each = var.subnet_ids

  id = each.value
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_ecs_cluster" "selected" {
  cluster_name = split("/", var.ecs_cluster_arn)[1]
}

data "aws_ecr_repository" "selected" {
  name = var.ecr_name
}

data "aws_iam_role" "task_execution" {
  name = var.task_execution_role_name
}

data "aws_iam_role" "task" {
  name = var.task_role_name
}

data "aws_kms_alias" "log" {
  count = var.logging_settings.kms_alias != null ? 1 : 0

  name = var.logging_settings.kms_alias
}

data "aws_lb_listener" "selected" {
  count = var.use_lb ? 1 : 0

  arn = var.listener_arn
}