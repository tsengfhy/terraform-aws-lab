resource "aws_security_group" "job" {
  name        = "${module.context.prefix}-sg-batch-job"
  description = "Security group for Batch job"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    prefix_list_ids = [data.aws_vpc_endpoint.s3.prefix_list_id]
  }

  tags = module.context.tags
}