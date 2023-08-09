module "endpoints" {
  count  = !var.enable_nat_gateway ? 1 : 0
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [one(aws_security_group.endpoints).id]

  endpoints = merge(
    {
      for endpoint in local.gateway_endpoints : endpoint => {
        service         = endpoint
        service_type    = "Gateway"
        route_table_ids = module.vpc.private_route_table_ids
        tags            = { Name = "${module.vpc.name}-gateway-${endpoint}" }
      }
    },
    {
      for endpoint in var.endpoints : endpoint => {
        service             = endpoint
        private_dns_enabled = true
        tags                = { Name = "${module.vpc.name}-interface-${endpoint}" }
      }
    },
  )

  tags = module.context.tags
}

resource "aws_security_group" "endpoints" {
  count       = !var.enable_nat_gateway ? 1 : 0
  name        = "${module.vpc.name}-endpoints"
  description = "Security group for endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.vpc_cidr]
  }

  tags = module.context.tags
}