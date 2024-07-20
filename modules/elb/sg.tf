resource "aws_security_group" "this" {
  name        = "${module.context.prefix}-sg-elb-${var.name}"
  description = "Security group for ELB ${var.name}"
  vpc_id      = data.aws_vpc.selected.id

  tags = module.context.tags
}

resource "aws_security_group_rule" "inbound" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = local.port
  to_port           = local.port
  cidr_blocks       = [var.internal ? data.aws_vpc.selected.cidr_block : local.anywhere_cidr]
}

resource "aws_security_group_rule" "outbound" {
  for_each = toset([for item in var.forwarded_ports : tostring(item)])

  security_group_id = aws_security_group.this.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}