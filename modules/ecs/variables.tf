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
    error_message = "Just fargate is supported"
  }
}