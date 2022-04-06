variable "environment" {
  type     = string
  nullable = false
}

variable "capacity_provider" {
  type    = string
  default = "FARGATE_SPOT"

  validation {
    condition     = can(index(["FARGATE", "FARGATE_SPOT"], var.capacity_provider))
    error_message = "Only fargate supported."
  }
}

variable "artifact_id" {
  type    = string
  default = "ecr-ecs"
}

variable "ecr_kms_key_id" {
  type    = string
  default = "alias/aws/ecr"
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "task_execution_role" {
  type     = string
  nullable = false
}

variable "task_role" {
  type     = string
  nullable = false
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "task_container_port" {
  type    = number
  default = 80
}

variable "task_env_key" {
  type    = string
  default = "ENVIRONMENT"
}

variable "secretsmanager_kms_key_id" {
  type    = string
  default = "alias/aws/secretsmanager"
}

variable "task_secrets" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "task_desired_count" {
  type    = number
  default = 1
}

variable "log_bucket_name" {
  type    = string
  default = null
}