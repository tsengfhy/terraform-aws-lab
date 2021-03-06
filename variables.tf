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

variable "create_ecs" {
  type    = bool
  default = false
}

variable "create_batch" {
  type    = bool
  default = false
}