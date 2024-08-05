variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type    = string
  default = "default"
}

variable "matching_event_types" {
  type    = list(string)
  default = ["BOUNCE", "COMPLAINT", "DELIVERY", "REJECT"]
}

variable "use_kms" {
  type    = bool
  default = false
}

variable "kms_alias" {
  type    = string
  default = null

  validation {
    condition     = !var.use_kms || var.kms_alias != null
    error_message = "KMS alias can not be null if enable KMS"
  }
}

variable "use_fifo" {
  type    = bool
  default = false
}