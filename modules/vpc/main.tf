module "context" {
  source = "../context"

  workspace = var.workspace
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                    = "${module.context.prefix}-vpc-${var.name}"
  cidr                    = var.cidr_block
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
  enable_nat_gateway      = var.use_nat_gateway

  azs             = slice(data.aws_availability_zones.available.names, 0, min(local.datacenters, length(data.aws_availability_zones.available.names)))
  public_subnets  = cidrsubnets(element(local.subnet_cidr_blocks, 0), 2, 2)
  private_subnets = cidrsubnets(element(local.subnet_cidr_blocks, 1), 2, 2)

  tags = module.context.tags
}

