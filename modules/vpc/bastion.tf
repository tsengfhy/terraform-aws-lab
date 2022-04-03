resource "aws_spot_instance_request" "bastion" {
  count                = var.enable_bastion ? 1 : 0
  ami                  = data.aws_ami.bastion.image_id
  instance_type        = var.bastion_instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_groups      = [one(aws_security_group.bastion).id]
  key_name             = var.key_pair_name
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

  tags = module.context.tags
}