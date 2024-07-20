resource "aws_spot_instance_request" "bastion" {
  count = var.use_bastion ? 1 : 0

  ami                    = data.aws_ssm_parameter.bastion_ami.value
  instance_type          = var.bastion_instance_type
  iam_instance_profile   = var.bastion_instance_profile
  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [one(aws_security_group.bastion).id]
  key_name               = var.bastion_key_name
  wait_for_fulfillment   = true

  tags = module.context.tags
}

resource "aws_security_group" "bastion" {
  count = var.use_bastion ? 1 : 0

  name        = "${module.vpc.name}-sg-bastion"
  description = "Security group for Bastion"
  vpc_id      = module.vpc.vpc_id

  tags = module.context.tags
}

resource "aws_security_group_rule" "icmp" {
  count = var.use_bastion && var.bastion_key_name != null ? 1 : 0

  security_group_id = one(aws_security_group.bastion).id
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = [local.anywhere_cidr_block]
}

resource "aws_security_group_rule" "ssh" {
  count = var.use_bastion && var.bastion_key_name != null ? 1 : 0

  security_group_id = one(aws_security_group.bastion).id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [local.anywhere_cidr_block]
}

resource "aws_security_group_rule" "outbound" {
  count = var.use_bastion ? 1 : 0

  security_group_id = one(aws_security_group.bastion).id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = [var.cidr_block]
}

resource "aws_security_group_rule" "s3" {
  count = var.use_bastion ? 1 : 0

  security_group_id = one(aws_security_group.bastion).id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.s3.id]
}
