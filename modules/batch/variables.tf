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
  default = "ecr-batch"
}

variable "ecr_kms_key_id" {
  type    = string
  default = "alias/aws/ecr"
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "batch_role" {
  type    = string
  default = "AWSServiceRoleForBatch"
}

variable "event_target_batch_role" {
  type     = string
  nullable = false
}

variable "job_execution_role" {
  type     = string
  nullable = false
}

variable "job_role" {
  type     = string
  nullable = false
}

variable "jobs" {
  type = map(object({
    vcpu   = optional(string)
    memory = optional(string)
  }))
  default = {}
}

variable "job_vcpu" {
  type    = string
  default = "0.25"
}

variable "job_memory" {
  type    = string
  default = "512"
}

variable "job_name_key" {
  type    = string
  default = "JOB_NAME"
}

variable "job_env_key" {
  type    = string
  default = "ENVIRONMENT"
}

variable "job_attempt_duration_seconds" {
  type    = number
  default = 300
}

variable "secretsmanager_kms_key_id" {
  type    = string
  default = "alias/aws/secretsmanager"
}

variable "job_secrets" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}