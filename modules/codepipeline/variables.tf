variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "execution_mode" {
  type    = string
  default = "SUPERSEDED"

  validation {
    condition     = can(index(["SUPERSEDED", "QUEUED", "PARALLEL"], var.execution_mode))
    error_message = "Only SUPERSEDED / QUEUED / PARALLEL is supported"
  }
}

variable "service_role_name" {
  type     = string
  nullable = false
}

variable "artifact_bucket_name" {
  type     = string
  nullable = false
}

variable "artifact_kms_alias" {
  type    = string
  default = "alias/aws/s3"
}

variable "variables" {
  type = list(object({
    name          = string
    default_value = optional(string)
    description   = optional(string)
  }))
  default = []
}

variable "stages" {
  type = list(object({
    name = string
    actions = list(object({
      category         = string
      owner            = string
      provider         = string
      version          = string
      name             = string
      region           = optional(string)
      run_order        = optional(string)
      role_arn         = optional(string)
      namespace        = optional(string)
      input_artifacts  = optional(list(string))
      output_artifacts = optional(list(string))
      configuration    = optional(map(string))
    }))
  }))
  default = []

  validation {
    condition     = length(var.stages) >= 2
    error_message = "Minimum of at least two stages is required"
  }

  validation {
    condition     = alltrue(flatten([for stage in var.stages : [for action in stage.actions : can(index(["Source", "Build", "Test", "Approval", "Deploy", "Invoke"], action.category))]]))
    error_message = "Only Source / Build / Test / Approval / Deploy / Invoke is supported"
  }

  validation {
    condition     = alltrue(flatten([for stage in var.stages : [for action in stage.actions : can(index(["AWS", "Custom", "ThirdParty"], action.owner))]]))
    error_message = "Only AWS / Custom / ThirdParty is supported"
  }
}

variable "triggers" {
  type = list(object({
    source_action_name = string
    pull_request = optional(object({
      events = optional(list(string))
      branches = optional(object({
        includes = optional(list(string))
        excludes = optional(list(string))
      }))
      file_paths = optional(object({
        includes = optional(list(string))
        excludes = optional(list(string))
      }))
    }))
    push = optional(object({
      branches = optional(object({
        includes = optional(list(string))
        excludes = optional(list(string))
      }))
      file_paths = optional(object({
        includes = optional(list(string))
        excludes = optional(list(string))
      }))
      tags = optional(object({
        includes = optional(list(string))
        excludes = optional(list(string))
      }))
    }))
  }))
  default = []

  validation {
    condition     = alltrue(flatten([for trigger in var.triggers : [for event in try(trigger.pull_request.events, []) : can(index(["OPEN", "UPDATED", "CLOSED"], event))]]))
    error_message = "Only OPEN / UPDATED / CLOSED is supported"
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