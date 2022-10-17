locals {
  workspace = terraform.workspace
  prefix    = length(var.prefix) == 0 ? "${local.workspace}-" : substr(var.prefix, length(var.prefix) - 1, 1) == "-" ? var.prefix : "${var.prefix}-"
}
