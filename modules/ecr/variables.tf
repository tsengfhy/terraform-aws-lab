variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "use_kms" {
  type    = bool
  default = true
}

variable "kms_alias" {
  type    = string
  default = "alias/aws/ecr"
}