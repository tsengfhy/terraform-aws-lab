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

variable "notification_email_addresses" {
  type    = list(string)
  default = []
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

    repo_name   = optional(string)
    branch_name = optional(string)
  }))
  default = {}
}

variable "pages" {
  type = map(object({
    alias = optional(string)
  }))
  default = {}
}

variable "job_config" {
  type = object({
    repo_name   = optional(string)
    branch_name = optional(string)
  })
  default = {}
}

variable "jobs" {
  type = map(object({
    schedule_expression = string
  }))
  default = {}
}

variable "state_machines" {
  type = map(object({
    use_notification = optional(bool, false)
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
    visibility_timeout_seconds = optional(number, 30)
    message_retention_seconds  = optional(number, 345600)
    delay_seconds              = optional(number, 0)
    receive_wait_time_seconds  = optional(number, 20)
    use_dlq                    = optional(bool, true)
    max_receive_count          = optional(number, 1)
  }))
  default = {}
}

variable "create_codepipeline" {
  type    = bool
  default = false
}

variable "artifact_bucket_key" {
  type    = string
  default = null
}