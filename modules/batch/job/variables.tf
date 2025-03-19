variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
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

variable "vcpu" {
  type    = string
  default = "0.25"
}

variable "memory" {
  type    = string
  default = "512"
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

variable "batch_service_scheduler_role_name" {
  type     = string
  nullable = false
}

variable "batch_job_queue_arn" {
  type     = string
  nullable = false
}

variable "log_retention_in_days" {
  type    = number
  default = 30
}

variable "log_kms_alias" {
  type    = string
  default = null
}

variable "log_skip_destroy" {
  type    = bool
  default = false
}
