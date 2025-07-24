variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type    = string
  default = "default"
}

variable "capacity_provider" {
  type    = string
  default = "FARGATE"

  validation {
    condition     = can(index(["FARGATE", "FARGATE_SPOT"], var.capacity_provider))
    error_message = "Only FARGATE is supported"
  }
}

variable "container_insights" {
  type    = string
  default = "disabled"

  validation {
    condition     = can(index(["enhanced", "enabled", "disabled"], var.container_insights))
    error_message = "Only enhanced / enabled / disabled is supported"
  }
}