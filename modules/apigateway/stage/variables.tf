variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "rest_api_id" {
  type     = string
  nullable = false
}

variable "deployment_id" {
  type     = string
  nullable = false
}

variable "documentation_version" {
  type    = string
  default = null
}

variable "client_certificate_id" {
  type    = string
  default = null
}

variable "variables" {
  type    = map(string)
  default = {}
}

variable "caching_settings" {
  type = object({
    size                                       = optional(number)
    data_encrypted                             = optional(bool, false)
    ttl_in_seconds                             = optional(number, 300)
    require_authorization_for_cache_control    = optional(bool, true)
    unauthorized_cache_control_header_strategy = optional(string, "SUCCEED_WITH_RESPONSE_HEADER")
  })
  default = {}

  validation {
    condition     = can(index(["FAIL_WITH_403", "SUCCEED_WITH_RESPONSE_HEADER", "SUCCEED_WITHOUT_RESPONSE_HEADER"], var.caching_settings.unauthorized_cache_control_header_strategy))
    error_message = "Only FAIL_WITH_403 / SUCCEED_WITH_RESPONSE_HEADER / SUCCEED_WITHOUT_RESPONSE_HEADER is supported"
  }
}

variable "throttling_settings" {
  type = object({
    rate_limit  = optional(number, -1)
    burst_limit = optional(number, -1)
  })
  default = {}
}

variable "logging_settings" {
  type = object({
    retention_in_days  = optional(number, 30)
    kms_alias          = optional(string)
    skip_destroy       = optional(bool, false)
    level              = optional(string, "OFF")
    data_trace_enabled = optional(bool, false)
  })
  default = {}

  validation {
    condition     = can(index(["OFF", "ERROR", "INFO"], var.logging_settings.level))
    error_message = "Only OFF / ERROR / INFO is supported"
  }
}

variable "use_xray" {
  type    = bool
  default = false
}

variable "domain_name" {
  type    = string
  default = null
}

variable "base_path" {
  type    = string
  default = null
}