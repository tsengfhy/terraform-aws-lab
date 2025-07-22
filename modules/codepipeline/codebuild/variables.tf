variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "service_role_name" {
  type     = string
  nullable = false
}

variable "environment" {
  type = object({
    type         = optional(string, "LINUX_CONTAINER")
    image        = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")
    compute_type = optional(string, "BUILD_GENERAL1_SMALL")
    certificate  = optional(string)
  })
  default = {}
}

variable "use_docker" {
  type    = bool
  default = false
}

variable "envs" {
  type = list(object({
    name  = string
    type  = optional(string, "PLAINTEXT")
    value = string
  }))
  default = []

  validation {
    condition     = alltrue([for env in var.envs : can(index(["PLAINTEXT", "PARAMETER_STORE", "SECRETS_MANAGER"], env.type))])
    error_message = "Only PLAINTEXT / PARAMETER_STORE / SECRETS_MANAGER is supported"
  }
}

variable "build_timeout" {
  type    = number
  default = 60
}

variable "queued_timeout" {
  type    = number
  default = 480
}

variable "vpc_config" {
  type = object({
    vpc_id             = optional(string)
    subnets            = optional(list(string))
    security_group_ids = optional(list(string))
  })
  default = null
}

variable "source_config" {
  type = object({
    type      = string
    location  = optional(string)
    buildspec = optional(string)
  })
  default = {
    type = "CODEPIPELINE"
  }

  validation {
    condition     = can(index(["NO_SOURCE", "CODEPIPELINE", "S3"], var.source_config.type))
    error_message = "Only NO_SOURCE / CODEPIPELINE / S3 is supported"
  }
}

variable "artifacts_config" {
  type = object({
    type      = string
    location  = optional(string)
    path      = optional(string)
    packaging = optional(string)
  })
  default = {
    type = "CODEPIPELINE"
  }

  validation {
    condition     = can(index(["NO_ARTIFACTS", "CODEPIPELINE", "S3"], var.artifacts_config.type))
    error_message = "Only NO_ARTIFACTS / CODEPIPELINE / S3 is supported"
  }

  validation {
    condition     = var.artifacts_config.packaging == null || can(index(["NONE", "ZIP"], var.artifacts_config.packaging))
    error_message = "Only NONE / ZIP is supported"
  }
}

variable "use_caching" {
  type    = bool
  default = false
}

variable "caching_bucket_name" {
  type    = string
  default = null

  validation {
    condition     = !var.use_caching || var.caching_bucket_name != null
    error_message = "The caching bucket name can not be null if enable caching"
  }
}

variable "logging_config" {
  type = object({
    retention_in_days = optional(number, 30)
    kms_alias         = optional(string)
    skip_destroy      = optional(bool, false)
  })
  default = {}
}