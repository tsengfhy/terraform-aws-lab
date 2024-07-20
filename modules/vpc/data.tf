locals {
  datacenters         = 2
  subnet_cidr_blocks  = cidrsubnets(var.cidr_block, 2, 2)
  anywhere_cidr_block = "0.0.0.0/0"

  gateway_endpoints = ["s3", "dynamodb"]
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_ssm_parameter" "bastion_ami" {
  name = var.bastion_ami_parameter_name
}
