resource "aws_dynamodb_table" "lock" {
  count          = var.create_lock_dynamodb ? 1 : 0
  name           = "${module.context.global_prefix}-terraform-lock"
  hash_key       = "LockID"
  write_capacity = 1
  read_capacity  = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = module.context.tags
}