variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
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

variable "vpc_endpoint_ids" {
  type    = list(string)
  default = null

  validation {
    condition     = var.type != "PRIVATE" || var.vpc_endpoint_ids != null
    error_message = "The vpc_endpoint_ids can not be null if type is PRIVATE"
  }
}

variable "body" {
  type    = string
  default = null
}

variable "disable_execute_api_endpoint" {
  type    = bool
  default = null
}

variable "api_key_source" {
  type    = string
  default = null

  validation {
    condition     = var.api_key_source == null || can(index(["HEADER", "AUTHORIZER"], var.api_key_source))
    error_message = "Only HEADER / AUTHORIZER is supported"
  }
}

variable "minimum_compression_size" {
  type    = string
  default = null
}

variable "binary_media_types" {
  type    = list(string)
  default = null
}

variable "parameters" {
  type    = map(string)
  default = {}
}

variable "policy" {
  type    = string
  default = null
}