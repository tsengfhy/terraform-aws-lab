variable "environment" {
  type     = string
  nullable = false
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "acm_certificate_arn" {
  type    = string
  default = null
}

variable "s3_kms_key_id" {
  type    = string
  default = "alias/aws/s3"
}

variable "log_bucket_name" {
  type    = string
  default = null
}