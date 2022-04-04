variable "region" {
  type     = string
  nullable = false
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "create_cloudfront" {
  type    = bool
  default = false
}