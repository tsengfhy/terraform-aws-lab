module "context" {
  source = "../context"

  environment = var.environment
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${module.context.prefix}-vpc-isolated"
  cidr                 = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = var.enable_nat_gateway

  azs                 = slice(data.aws_availability_zones.available.names, 0, min(local.datacenter_count, length(data.aws_availability_zones.available.names)))
  public_subnets      = cidrsubnets(local.subnets_cidr[0], 2, 2)
  public_subnet_tags  = local.public_subnet_tags
  private_subnets     = cidrsubnets(local.subnets_cidr[1], 2, 2)
  private_subnet_tags = local.private_subnet_tags

  tags = module.context.tags
}

