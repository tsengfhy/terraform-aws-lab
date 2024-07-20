module "endpoints" {
  count  = !var.use_nat_gateway ? 1 : 0
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = length(var.interface_endpoints) > 0 ? [one(aws_security_group.endpoint).id] : []

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
      for endpoint in var.interface_endpoints : endpoint => {
        service             = endpoint
        private_dns_enabled = true
        tags                = { Name = "${module.vpc.name}-interface-${endpoint}" }
      }
    },
  )

  tags = module.context.tags
}

resource "aws_security_group" "endpoint" {
  count = !var.use_nat_gateway && length(var.interface_endpoints) > 0 ? 1 : 0

  name        = "${module.vpc.name}-sg-endpoint"
  description = "Security group for Endpoint"
  vpc_id      = module.vpc.vpc_id

  tags = module.context.tags
}

resource "aws_security_group_rule" "https" {
  count = !var.use_nat_gateway && length(var.interface_endpoints) > 0 ? 1 : 0

  security_group_id = one(aws_security_group.endpoint).id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [var.cidr_block]
}
