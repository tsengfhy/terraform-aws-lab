module "s3" {
  for_each = var.buckets
  source   = "../modules/s3"

  workspace = local.workspace

  name                  = each.key
  force_destroy         = each.value.force_destroy
  use_versioning        = each.value.use_versioning
  use_logging           = each.value.use_logging
  logging_bucket_name   = data.aws_s3_bucket.log.bucket
  use_default_lifecycle = each.value.use_default_lifecycle
}

module "sqs" {
  for_each = var.queues
  source   = "../modules/sqs"

  workspace = local.workspace

  name                       = each.key
  use_fifo                   = each.value.use_fifo
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = each.value.message_retention_seconds
  delay_seconds              = each.value.delay_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds
  use_dlq                    = each.value.use_dlq
  max_receive_count          = each.value.max_receive_count
}

module "ecr" {
  for_each = local.repos
  source   = "../modules/ecr"

  workspace = local.workspace

  name          = each.key
  force_destroy = lookup(each.value, "force_destroy")
}

module "secretsmanager" {
  for_each = local.secrets
  source   = "../modules/secretsmanager"

  workspace = local.workspace

  name          = each.key
  description   = lookup(each.value, "description")
  secret_string = lookup(each.value, "secret_string")
  secret_keys   = lookup(each.value, "secret_keys")
}