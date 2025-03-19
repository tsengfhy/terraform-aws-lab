locals {
  service = "batch"
}

data "aws_region" "current" {}

data "aws_ecr_repository" "selected" {
  name = var.ecr_name
}

data "aws_iam_role" "task_execution" {
  name = var.task_execution_role_name
}

data "aws_iam_role" "task" {
  name = var.task_role_name
}

data "aws_iam_role" "batch_service_scheduler" {
  name = var.batch_service_scheduler_role_name
}

data "aws_batch_job_queue" "selected" {
  name = split("/", var.batch_job_queue_arn)[1]
}

data "aws_kms_alias" "log" {
  count = var.log_kms_alias != null ? 1 : 0

  name = var.log_kms_alias
}