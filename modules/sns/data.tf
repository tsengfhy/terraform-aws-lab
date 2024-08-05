locals {
  suffix = var.use_fifo ? ".fifo" : ""
}

data "aws_kms_alias" "selected" {
  count = var.use_kms ? 1 : 0

  name = var.kms_alias
}