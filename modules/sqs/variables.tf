variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "use_kms" {
  type    = bool
  default = true
}

variable "kms_alias" {
  type    = string
  default = "alias/aws/sqs"
}

variable "use_fifo" {
  type    = bool
  default = false
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

variable "message_retention_seconds" {
  type    = number
  default = 345600
}

variable "delay_seconds" {
  type    = number
  default = 0
}

variable "receive_wait_time_seconds" {
  type    = number
  default = 20
}

variable "use_dlq" {
  type    = bool
  default = true
}

variable "max_receive_count" {
  type    = number
  default = 1
}