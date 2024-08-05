variable "workspace" {
  type     = string
  nullable = false
}

variable "domain" {
  type     = string
  nullable = false
}

variable "use_spf" {
  type    = bool
  default = true
}

variable "mail_from_alias" {
  type    = string
  default = null

  validation {
    condition     = !var.use_spf || var.mail_from_alias != null
    error_message = "Mail from can not be null if enable SPF"
  }
}

variable "use_dns" {
  type    = bool
  default = false
}