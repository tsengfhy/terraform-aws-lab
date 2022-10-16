variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "prefix" {
  type    = string
  default = ""
}

variable "workspaces" {
  type    = list(string)
  default = []
}

variable "worksapce_tag_key" {
  type = string
  default = "Environment"
}

variable "notification_email_addresses" {
  type    = list(string)
  default = []
}

variable "cost_limit_amont" {
  type    = string
  default = "1"
}

variable "cost_anomaly_amont" {
  type    = string
  default = "1"
}
