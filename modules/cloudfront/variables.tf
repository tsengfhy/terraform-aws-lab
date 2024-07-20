variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "use_caching" {
  type    = bool
  default = true
}

variable "use_dns" {
  type    = bool
  default = false
}

variable "domain" {
  type    = string
  default = null

  validation {
    condition     = !var.use_dns || var.domain != null
    error_message = "The domain can not be null if enable DNS"
  }
}

variable "alias" {
  type    = string
  default = null

  validation {
    condition     = !var.use_dns || var.alias != null
    error_message = "The alias can not be null if enable DNS"
  }
}

variable "web_acl_id" {
  type    = string
  default = null
}

variable "use_ipv6" {
  type    = bool
  default = false
}

variable "use_logging" {
  type    = bool
  default = false
}

variable "log_bucket_name" {
  type    = string
  default = null

  validation {
    condition     = !var.use_logging || var.log_bucket_name != null
    error_message = "The log bucket name can not be null if enable logging"
  }
}

variable "enabled" {
  type    = bool
  default = false
}