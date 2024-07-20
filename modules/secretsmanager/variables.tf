variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "description" {
  type    = string
  default = null
}

variable "kms_alias" {
  type    = string
  default = "alias/aws/secretsmanager"
}

variable "secret_string" {
  type    = string
  default = null
}

variable "secret_keys" {
  type    = list(string)
  default = []
}