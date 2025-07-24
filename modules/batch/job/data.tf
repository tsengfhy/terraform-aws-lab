locals {
  service = "batch"
  name    = "${module.context.prefix}-batch-job-${var.name}"
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

data "aws_iam_role" "scheduler" {
  name = var.scheduler_role_name
}

data "aws_batch_job_queue" "selected" {
  name = split("/", var.job_queue_arn)[1]
}

data "aws_kms_alias" "log" {
  count = var.logging_config.kms_alias != null ? 1 : 0

  name = var.logging_config.kms_alias
}