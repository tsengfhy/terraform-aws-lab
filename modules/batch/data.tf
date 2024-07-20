locals {
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

data "aws_iam_role" "batch_service" {
  name = var.batch_service_role_name
}