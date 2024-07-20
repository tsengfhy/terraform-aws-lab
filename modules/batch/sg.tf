resource "aws_security_group" "this" {
  name        = "${module.context.prefix}-sg-batch-${var.name}"
  description = "Security group for Batch ${var.name}"
  vpc_id      = data.aws_vpc.selected.id

  tags = module.context.tags
}

resource "aws_security_group_rule" "endpoint" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group_rule" "s3" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.s3.id]
}