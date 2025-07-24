variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type    = string
  default = "default"
}

variable "service_role_name" {
  type    = string
  default = "AWSServiceRoleForBatch"
}

variable "capacity_provider" {
  type    = string
  default = "FARGATE"

  validation {
    condition     = can(index(["FARGATE", "FARGATE_SPOT"], var.capacity_provider))
    error_message = "Only fargate is supported"
  }
}

variable "subnet_ids" {
  type     = list(string)
  nullable = false
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}