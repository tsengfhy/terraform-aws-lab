data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  tags   = var.private_subnet_tags
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_kms_key" "ecr" {
  key_id = var.ecr_kms_key_id
}

data "aws_kms_key" "secretsmanager" {
  key_id = var.secretsmanager_kms_key_id
}

data "aws_iam_role" "batch_role" {
  name = var.batch_role
}

data "aws_iam_role" "event_target_batch_role" {
  name = var.event_target_batch_role
}

data "aws_iam_role" "job_execution_role" {
  name = var.job_execution_role
}

data "aws_iam_role" "job_role" {
  name = var.job_role
}