variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "type" {
  type    = string
  default = "STANDARD"

  validation {
    condition     = can(index(["STANDARD", "EXPRESS"], var.type))
    error_message = "Only STANDARD / EXPRESS is supported"
  }
}

variable "definition" {
  type     = string
  nullable = false
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

variable "logging_config" {
  type = object({
    retention_in_days      = optional(number, 30)
    kms_alias              = optional(string)
    skip_destroy           = optional(bool, false)
    level                  = optional(string, "ALL")
    include_execution_data = optional(bool, false)
  })
  default = {}

  validation {
    condition     = can(index(["ALL", "ERROR", "FATAL", "OFF"], var.logging_config.level))
    error_message = "Only ALL / ERROR / FATAL / OFF is supported"
  }
}

variable "use_xray" {
  type    = bool
  default = false
}
