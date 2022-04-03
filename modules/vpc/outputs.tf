output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "azs" {
  value = module.vpc.azs
}

output "public_subnet_tags" {
  value = local.public_subnet_tags
}

output "private_subnet_tags" {
  value = local.private_subnet_tags
}