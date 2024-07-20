variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type    = string
  default = "isolated"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "use_nat_gateway" {
  type    = bool
  default = false
}

variable "interface_endpoints" {
  type    = list(string)
  default = []
}

variable "use_bastion" {
  type    = bool
  default = false
}

variable "bastion_ami_parameter_name" {
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.nano"
}

variable "bastion_instance_profile" {
  type    = string
  default = null
}

variable "bastion_key_name" {
  type    = string
  default = null
}