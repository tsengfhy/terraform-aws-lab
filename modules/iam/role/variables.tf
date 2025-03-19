variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "path" {
  type    = string
  default = "/"
}

variable "description" {
  type    = string
  default = null
}

variable "is_service_linked" {
  type    = bool
  default = false
}

variable "force_detach_policies" {
  type    = bool
  default = false
}

variable "max_session_duration" {
  type    = number
  default = 3600
}

variable "assume_role_policy" {
  type     = string
  nullable = false
}

variable "managed_policy_arns" {
  type    = set(string)
  default = []
}

variable "inline_policies" {
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}