locals {
  datacenter_count    = 2
  anywhere_cidr       = "0.0.0.0/0"
  subnets_cidr        = cidrsubnets(var.vpc_cidr, 4, 4)
  public_subnet_tags  = { Category = "public" }
  private_subnet_tags = { Category = "private" }

  gateway_endpoints = ["s3", "dynamodb"]
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_ami" "bastion" {
  owners      = ["amazon"]
  name_regex  = var.bastion_ami_name_regex
  most_recent = true
}