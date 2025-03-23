variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "filename" {
  type    = string
  default = null
}

variable "s3_bucket" {
  type    = string
  default = null
}

variable "s3_key" {
  type    = string
  default = null

  validation {
    condition     = var.s3_bucket == null || var.s3_key != null
    error_message = "The s3_key can not be null if s3_bucket is set"
  }
}

variable "image_uri" {
  type    = string
  default = null
}

variable "source_code_hash" {
  type    = string
  default = null
}

variable "layers" {
  type    = list(string)
  default = []
}

variable "runtime" {
  type     = string
  nullable = false
}

variable "architecture" {
  type    = string
  default = "x86_64"

  validation {
    condition     = can(index(["x86_64", "arm64"], var.architecture))
    error_message = "Only x86_64 / arm64 is supported"
  }
}

variable "handler" {
  type     = string
  nullable = false
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "ephemeral_storage" {
  type    = number
  default = 512

  validation {
    condition     = var.ephemeral_storage >= 512 && var.ephemeral_storage <= 10240
    error_message = "The minimum supported ephemeral_storage value is 512MB and the maximum supported value is 10240MB"
  }
}

variable "reserved_concurrent_executions" {
  type    = number
  default = -1
}

variable "timeout" {
  type    = number
  default = 3
}

variable "envs" {
  type = list(object({
    name  = string,
    value = string
  }))
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "use_dlq" {
  type    = bool
  default = false
}

variable "dlq_kms_alias" {
  type    = string
  default = "alias/aws/sqs"
}

variable "maximum_event_age_in_seconds" {
  type    = number
  default = 21600
}

variable "maximum_retry_attempts" {
  type    = number
  default = 2
}

variable "logging_settings" {
  type = object({
    retention_in_days = optional(number, 30)
    kms_alias         = optional(string)
    skip_destroy      = optional(bool, false)
    system_level      = optional(string, "INFO")
    application_level = optional(string, "INFO")
  })
  default = {}

  validation {
    condition     = can(index(["DEBUG", "INFO", "WARN"], var.logging_settings.system_level))
    error_message = "Only DEBUG / INFO / WARN is supported"
  }

  validation {
    condition     = can(index(["TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"], var.logging_settings.application_level))
    error_message = "Only TRACE / DEBUG / INFO / WARN / ERROR / FATAL is supported"
  }
}