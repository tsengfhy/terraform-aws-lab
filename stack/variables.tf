variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "create_bastion" {
  type    = bool
  default = false
}

variable "domain" {
  type    = string
  default = null
}

variable "apis" {
  type = map(object({
    alias = optional(string)
  }))
  default = {}
}

variable "services" {
  type = map(object({
    container_port = number
    health_check   = string
    priority       = optional(number)
    path_pattern   = string
    stickiness     = optional(bool, false)
  }))
  default = {}
}

variable "pages" {
  type = map(object({
    alias = optional(string)
  }))
  default = {}
}

variable "jobs" {
  type = map(object({
    schedule_expression = string
  }))
  default = {}
}

variable "buckets" {
  type = map(object({
    force_destroy         = optional(bool, false)
    use_versioning        = optional(bool, false)
    use_logging           = optional(bool, false)
    use_default_lifecycle = optional(bool, false)
  }))
  default = {}
}

variable "queues" {
  type = map(object({
    use_fifo                   = optional(bool, false)
    delay_seconds              = optional(number, 0)
    visibility_timeout_seconds = optional(number, 30)
    message_retention_seconds  = optional(number, 345600)
    use_dlq                    = optional(bool, true)
    max_receive_count          = optional(number, 1)
  }))
  default = {}
}