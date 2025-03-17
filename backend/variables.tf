variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "s3_kms_alias" {
  type    = string
  default = "alias/aws/s3"
}

variable "backend_config_filename" {
  type    = string
  default = "backend-config.tfvars"
}