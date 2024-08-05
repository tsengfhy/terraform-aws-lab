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
  default = "alias/aws/sns"
}

variable "use_fifo" {
  type    = bool
  default = false
}