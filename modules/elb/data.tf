locals {
  vpc_ids       = [for key, value in data.aws_subnet.selected : value.vpc_id]
  anywhere_cidr = "0.0.0.0/0"

  protocol = var.type == "application" ? (var.use_dns ? "HTTPS" : "HTTP") : (var.use_dns ? "TLS" : "TCP")
  port     = var.use_dns ? "443" : "80"
}

data "aws_vpc" "selected" {
  id = element(local.vpc_ids, 0)

  lifecycle {
    precondition {
      condition     = length(toset(local.vpc_ids)) == 1
      error_message = "The subnet ids are not for the same VPC"
    }
  }
}

data "aws_subnet" "selected" {
  for_each = var.subnet_ids

  id = each.value
}

data "aws_s3_bucket" "log" {
  count = var.use_logging ? 1 : 0

  bucket = var.log_bucket_name
}

data "aws_acm_certificate" "selected" {
  count = var.use_dns ? 1 : 0

  domain   = var.domain
  statuses = ["ISSUED"]
}