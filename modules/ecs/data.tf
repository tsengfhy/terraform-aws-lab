locals {
  anywhere_cidr = "0.0.0.0/0"
  alb_port      = 80
}

data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id
  tags   = var.public_subnet_tags
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  tags   = var.private_subnet_tags
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_kms_key" "ecr" {
  key_id = var.ecr_kms_key_id
}

data "aws_kms_key" "secretsmanager" {
  key_id = var.secretsmanager_kms_key_id
}

data "aws_iam_role" "task_execution_role" {
  name = var.task_execution_role
}

data "aws_iam_role" "task_role" {
  name = var.task_role
}

data "aws_s3_bucket" "log" {
  count  = var.log_bucket_name != null ? 1 : 0
  bucket = var.log_bucket_name
}