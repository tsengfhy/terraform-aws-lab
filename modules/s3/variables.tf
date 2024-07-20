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

variable "object_ownership" {
  type    = string
  default = "BucketOwnerEnforced"
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

variable "policy_documents" {
  type    = list(string)
  default = []
}

variable "use_transition_lifecycle" {
  type    = bool
  default = false
}

variable "transition_in_days" {
  type    = number
  default = 30
}

variable "use_expiration_lifecycle" {
  type    = bool
  default = false
}

variable "expiration_in_days" {
  type    = number
  default = 180
}

variable "use_logging" {
  type    = bool
  default = false
}

variable "log_bucket_name" {
  type    = string
  default = null

  validation {
    condition     = !var.use_logging || var.log_bucket_name != null
    error_message = "The log bucket name can not be null if enable logging"
  }
}