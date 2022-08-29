locals {
  prefix = length(var.prefix) == 0 || substr(var.prefix, length(var.prefix) - 1, 1) == "-" ? var.prefix : "${var.prefix}-"
}