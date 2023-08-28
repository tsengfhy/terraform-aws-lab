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
  type    = list(string)
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

variable "log_bucket_support_services" {
  type    = list(string)
  default = ["logging.s3"]
}

variable "log_bucket_support_buckets" {
  type    = list(string)
  default = []
}
