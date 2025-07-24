variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "vcpu" {
  type    = string
  default = "0.25"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "task_execution_role_name" {
  type     = string
  nullable = false
}

variable "task_role_name" {
  type     = string
  nullable = false
}

variable "ecr_name" {
  type     = string
  nullable = false
}

variable "ecr_image_tag" {
  type    = string
  default = "latest"
}

variable "envs" {
  type = list(object({
    name  = string,
    value = string
  }))
  default = []
}

variable "secrets" {
  type = list(object({
    name      = string,
    valueFrom = string
  }))
  default = []
}

variable "attempt_duration_seconds" {
  type    = number
  default = 300
}

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "schedule_expression" {
  type     = string
  nullable = false
}

variable "enabled" {
  type    = bool
  default = false
}

variable "scheduler_role_name" {
  type     = string
  nullable = false
}

variable "job_queue_arn" {
  type     = string
  nullable = false
}

variable "logging_config" {
  type = object({
    retention_in_days = optional(number, 30)
    kms_alias         = optional(string)
    skip_destroy      = optional(bool, false)
  })
  default = {}
}
