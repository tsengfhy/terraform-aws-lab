module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_batch_compute_environment" "this" {
  name         = "${module.context.prefix}-batch-${var.name}"
  type         = "MANAGED"
  service_role = data.aws_iam_role.batch_service.arn

  compute_resources {
    type               = var.capacity_provider
    max_vcpus          = 256
    subnets            = [for key, value in data.aws_subnet.selected : value.id]
    security_group_ids = concat([aws_security_group.this.id], var.security_group_ids)
  }

  tags = module.context.tags
}

resource "aws_batch_job_queue" "this" {
  name     = "${module.context.prefix}-batch-queue-${var.name}"
  state    = "ENABLED"
  priority = 1

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.this.arn
  }

  tags = module.context.tags
}



