variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "ecs_cluster_arn" {
  type     = string
  nullable = false
}

variable "use_execute_command" {
  type    = bool
  default = false
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type     = list(string)
  nullable = false
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
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

variable "container_port" {
  type     = number
  nullable = false
}

variable "health_check" {
  type     = string
  nullable = false
}

variable "health_check_grace_period_seconds" {
  type    = number
  default = 0
}

variable "logging_config" {
  type = object({
    retention_in_days = optional(number, 30)
    kms_alias         = optional(string)
    skip_destroy      = optional(bool, false)
  })
  default = {}
}

variable "use_lb" {
  type    = bool
  default = false
}

variable "listener_arn" {
  type    = string
  default = null

  validation {
    condition     = !var.use_lb || var.listener_arn != null
    error_message = "Listener arn can not be null if enable Load Balance"
  }
}

variable "priority" {
  type    = number
  default = null
}

variable "path_pattern" {
  type    = string
  default = null

  validation {
    condition     = !var.use_lb || var.path_pattern != null
    error_message = "Path pattern can not be null if enable Load Balance"
  }
}

variable "stickiness" {
  type    = bool
  default = false
}