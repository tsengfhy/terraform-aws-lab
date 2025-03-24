variable "workspace" {
  type     = string
  nullable = false
}

variable "domain" {
  type     = string
  nullable = false
}

variable "alias" {
  type     = string
  nullable = false
}

variable "type" {
  type    = string
  default = "REGIONAL"

  validation {
    condition     = can(index(["EDGE", "REGIONAL", "PRIVATE"], var.type))
    error_message = "Only EDGE / REGIONAL / PRIVATE is supported"
  }
}

variable "policy" {
  type    = string
  default = null

  validation {
    condition     = var.type == "PRIVATE" || var.policy == null
    error_message = "Only supported for PRIVATE domain name"
  }
}

variable "vpc_endpoint_ids" {
  type    = list(string)
  default = []

  validation {
    condition     = var.type == "PRIVATE" || length(var.vpc_endpoint_ids) == 0
    error_message = "Only supported for PRIVATE domain name"
  }
}

variable "use_dns" {
  type    = bool
  default = false
}