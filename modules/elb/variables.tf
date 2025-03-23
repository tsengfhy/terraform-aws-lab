variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type    = string
  default = "default"
}

variable "type" {
  type    = string
  default = "application"

  validation {
    condition     = can(index(["application", "network"], var.type))
    error_message = "Load balancer type is not supported"
  }
}

variable "internal" {
  type    = bool
  default = false
}

variable "use_ipv6" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type     = set(string)
  nullable = false
}

variable "idle_timeout" {
  type    = number
  default = 60
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

variable "use_dns" {
  type    = bool
  default = false
}

variable "domain" {
  type    = string
  default = null

  validation {
    condition     = !var.use_dns || var.domain != null
    error_message = "The domain can not be null if enable DNS"
  }
}

variable "alias" {
  type    = string
  default = null

  validation {
    condition     = !var.use_dns || var.alias != null
    error_message = "The alias can not be null if enable DNS"
  }
}

variable "action" {
  type = object({
    type             = string
    status_code      = optional(string)
    content_type     = optional(string)
    message_body     = optional(string)
    protocol         = optional(string, "#{protocol}")
    host             = optional(string, "#{host}")
    port             = optional(string, "#{port}")
    path             = optional(string, "/#{path}")
    query            = optional(string, "#{query}")
    target_group_arn = optional(string)
  })

  default = {
    type         = "fixed-response"
    status_code  = "404"
    content_type = "application/json"
    message_body = <<EOL
    {
      status  = 404
      error   = "Not Found"
      message = "No message available"
    }
    EOL
  }

  validation {
    condition     = can(index(["forward", "redirect", "fixed-response"], var.action.type))
    error_message = "Action type is not supported"
  }

  validation {
    condition     = var.action.type != "forward" || var.action.target_group_arn != null
    error_message = "Target group arn can not be null if type is 'forward'"
  }
}

variable "forwarded_ports" {
  type    = set(number)
  default = []
}