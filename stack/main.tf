module "context" {
  source = "../modules/context"

  workspace = local.workspace
}

module "vpc" {
  source = "../modules/vpc"

  workspace = local.workspace

  use_nat_gateway = false
  interface_endpoints = local.create_ecs || local.create_batch ? [
    "ecr.api",
    "ecr.dkr",
    "logs",
    "monitoring",
    "secretsmanager",
  ] : []

  use_bastion      = var.create_bastion
  bastion_key_name = var.create_bastion ? one(aws_key_pair.bastion).key_name : null
}

resource "aws_key_pair" "bastion" {
  count = var.create_bastion ? 1 : 0

  key_name   = "${module.context.prefix}-key-bastion"
  public_key = file("${path.module}/certs/default.pub")
}
