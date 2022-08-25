variable "environment" {
  type     = string
  nullable = false
}

variable "sqs_kms_key_id" {
  type    = string
  default = "alias/aws/sqs"
}

variable "queues" {
  type = map(object({
    enable_fifo                = optional(bool)
    delay_seconds              = optional(number)
    visibility_timeout_seconds = optional(number)
    message_retention_seconds  = optional(number)
    enable_dlq                 = optional(bool)
    max_receive_count          = optional(number)
  }))
  default = {}
}