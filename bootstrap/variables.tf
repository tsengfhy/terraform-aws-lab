variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "notification_email_addresses" {
  type    = list(string)
  default = []
}

variable "workspace_tag_key" {
  type    = string
  default = "Workspace"
}

variable "workspaces" {
  type    = set(string)
  default = []
}

variable "cost_limit_amount" {
  type    = string
  default = "1"
}

variable "cost_anomaly_amount" {
  type    = string
  default = "1"
}

variable "domain" {
  type    = string
  default = null
}

variable "log_bucket_supported_services" {
  type    = set(string)
  default = ["logging.s3"]
}

variable "log_bucket_supported_buckets" {
  type    = set(string)
  default = []
}
