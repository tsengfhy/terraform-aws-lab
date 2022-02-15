variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}