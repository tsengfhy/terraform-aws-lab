variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "s3_kms_key_id" {
  type    = string
  default = "alias/aws/s3"
}

variable "create_log_bucket" {
  type    = bool
  default = false
}

variable "log_bucket_support_services" {
  type    = list(string)
  default = ["logging.s3"]
}

variable "backend_config_filename" {
  type    = string
  default = "backend-config.tfvars"
}
