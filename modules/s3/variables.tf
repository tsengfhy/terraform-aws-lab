variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "use_versioning" {
  type    = bool
  default = false
}

variable "use_kms" {
  type    = bool
  default = true
}

variable "kms_alias" {
  type    = string
  default = "alias/aws/s3"
}

variable "use_logging" {
  type    = bool
  default = false
}

variable "logging_bucket_name" {
  type    = string
  default = null

  validation {
    condition     = !var.use_logging || var.logging_bucket_name != null
    error_message = "The logging bucket name can not be null if enable logging"
  }
}

variable "policy_documents" {
  type    = list(string)
  default = []
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerEnforced"
}

variable "use_default_lifecycle" {
  type    = bool
  default = false
}