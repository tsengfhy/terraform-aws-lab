resource "aws_spot_instance_request" "bastion" {
  count                = var.enable_bastion ? 1 : 0
  ami                  = data.aws_ami.bastion.image_id
  instance_type        = var.bastion_instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_groups      = [one(aws_security_group.bastion).id]
  key_name             = var.key_pair_name
  iam_instance_profile = var.bastion_instance_profile
  wait_for_fulfillment = true

  tags = module.context.tags
}

resource "aws_security_group" "bastion" {
  count       = var.enable_bastion ? 1 : 0
  name        = "${module.vpc.name}-bastion"
  description = "Security group for bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [local.anywhere_cidr]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [local.anywhere_cidr]
  }

  egress {
    protocol    = "all"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.s3.id]
  }

  tags = module.context.tags
}