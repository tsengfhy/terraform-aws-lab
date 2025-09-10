variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type    = string
  default = "default"
}

variable "scope" {
  type    = string
  default = "REGIONAL"

  validation {
    condition     = can(index(["CLOUDFRONT", "REGIONAL"], var.scope))
    error_message = "Only CLOUDFRONT / REGIONAL is supported"
  }
}

variable "managed_rule_groups" {
  type = list(object({
    name     = string
    priority = number
    statement = object({
      name                  = string
      vendor_name           = string
      version               = optional(string)
      rule_action_overrides = optional(list(string), [])
    })
    use_override_action  = optional(bool, false)
    use_metrics          = optional(bool, false)
    use_sampled_requests = optional(bool, false)
  }))
  default = []
}

variable "rule_groups" {
  type = list(object({
    name     = string
    priority = number
    statement = object({
      arn                   = string
      rule_action_overrides = optional(list(string), [])
    })
    use_override_action  = optional(bool, false)
    use_metrics          = optional(bool, false)
    use_sampled_requests = optional(bool, false)
  }))
  default = []
}

variable "rate_based_rules" {
  type = list(object({
    name     = string
    priority = number
    statement = object({
      limit                 = number
      evaluation_window_sec = optional(number, 300)
      aggregate_key_type    = optional(string, "IP")
      custom_key = optional(object({
        ip           = optional(object({}))
        forwarded_ip = optional(object({}))
        http_method  = optional(object({}))
        uri_path = optional(object({
          text_transformations = optional(list(object({
            priority = number
            type     = string
            })), [
            {
              priority = 0
              type     = "NONE"
            },
          ])
        }))
        query_string = optional(object({
          text_transformations = optional(list(object({
            priority = number
            type     = string
            })), [
            {
              priority = 0
              type     = "NONE"
            },
          ])
        }))
        query_arguments = optional(list(object({
          name = string
          text_transformations = optional(list(object({
            priority = number
            type     = string
            })), [
            {
              priority = 0
              type     = "NONE"
            },
          ])
        })), [])
        headers = optional(list(object({
          name = string
          text_transformations = optional(list(object({
            priority = number
            type     = string
            })), [
            {
              priority = 0
              type     = "NONE"
            },
          ])
        })), [])
        cookies = optional(list(object({
          name = string
          text_transformations = optional(list(object({
            priority = number
            type     = string
            })), [
            {
              priority = 0
              type     = "NONE"
            },
          ])
        })), [])
        label_namespaces = optional(list(string), [])
      }), {})
      forwarded_ip_config = optional(object({
        header_name       = string
        fallback_behavior = string
      }))
    })
    action = object({
      type              = string
      request_headers   = optional(map(string), {})
      response_code     = optional(string)
      response_headers  = optional(map(string), {})
      repsonse_body_key = optional(string)
    })
    rule_labels          = optional(list(string), [])
    use_metrics          = optional(bool, false)
    use_sampled_requests = optional(bool, false)
  }))
  default = []

  validation {
    condition     = alltrue([for rule in var.rate_based_rules : can(index(["IP", "FORWARDED_IP", "CUSTOM_KEYS", "CONSTANT"], coalesce(rule.statement.aggregate_key_type, "IP")))])
    error_message = "Only IP / FORWARDED_IP / CUSTOM_KEYS / CONSTANT is supported"
  }

  validation {
    condition     = alltrue([for rule in var.rate_based_rules : can(index(["BLOCK", "COUNT", "CAPTCHA", "CHALLENGE"], rule.action.type))])
    error_message = "Only BLOCK / COUNT / CAPTCHA / CHALLENGE is supported"
  }
}

variable "default_action" {
  type = object({
    type              = string
    request_headers   = optional(map(string), {})
    response_code     = optional(string)
    response_headers  = optional(map(string), {})
    repsonse_body_key = optional(string)
  })
  default = {
    type = "ALLOW"
  }

  validation {
    condition     = can(index(["ALLOW", "BLOCK"], var.default_action.type))
    error_message = "Action type is not supported"
  }
}

variable "response_bodies" {
  type = list(object({
    key          = string
    content_type = string
    content      = string
  }))
  default = []

  validation {
    condition     = alltrue([for response_body in var.response_bodies : can(index(["TEXT_PLAIN", "TEXT_HTML", "APPLICATION_JSON"], response_body.content_type))])
    error_message = "Only TEXT_PLAIN / TEXT_HTML / APPLICATION_JSON is supported"
  }
}

variable "use_metrics" {
  type    = bool
  default = false
}

variable "use_sampled_requests" {
  type    = bool
  default = false
}

variable "use_logging" {
  type    = bool
  default = false
}

variable "logging_config" {
  type = object({
    retention_in_days = optional(number, 30)
    kms_alias         = optional(string)
    skip_destroy      = optional(bool, false)
    redacted_headers  = optional(list(string), [])
    filter = optional(object({
      default_behavior = string
      behavior         = string
      requirement      = string
      condition = list(object({
        action     = optional(string)
        label_name = optional(string)
      }))
    }))
  })
  default = {}

  validation {
    condition     = can(index(["KEEP", "DROP"], try(var.logging_config.filter.default_behavior, "KEEP")))
    error_message = "Only KEEP / DROP is supported"
  }

  validation {
    condition     = can(index(["KEEP", "DROP"], try(var.logging_config.filter.behavior, "KEEP")))
    error_message = "Only KEEP / DROP is supported"
  }

  validation {
    condition     = can(index(["MEETS_ALL", "MEETS_ANY"], try(var.logging_config.filter.requirement, "MEETS_ALL")))
    error_message = "Only MEETS_ALL / MEETS_ANY is supported"
  }

  validation {
    condition     = alltrue([for condition in try(var.logging_config.filter.condition, []) : can(index(["ALLOW", "BLOCK", "COUNT", "CAPTCHA", "CHALLENGE", "EXCLUDED_AS_COUNT"], coalesce(condition.action, "ALLOW")))])
    error_message = "Only ALLOW / BLOCK / COUNT / CAPTCHA / CHALLENGE / EXCLUDED_AS_COUNT is supported"
  }
}