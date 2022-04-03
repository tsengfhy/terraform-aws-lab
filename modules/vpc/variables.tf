variable "environment" {
  type     = string
  nullable = false
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "endpoints" {
  type    = list(string)
  default = []
}

variable "enable_bastion" {
  type    = bool
  default = false
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "bastion_ami_name_regex" {
  type    = string
  default = "^amzn2-ami-kernel"
}

variable "key_pair_name" {
  type    = string
  default = null
}