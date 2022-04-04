data "aws_kms_key" "s3" {
  key_id = var.s3_kms_key_id
}

data "aws_s3_bucket" "log" {
  count  = var.log_bucket_name != null ? 1 : 0
  bucket = var.log_bucket_name
}