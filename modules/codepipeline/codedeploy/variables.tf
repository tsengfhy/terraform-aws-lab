variable "workspace" {
  type     = string
  nullable = false
}

variable "name" {
  type     = string
  nullable = false
}

variable "compute_platform" {
  type     = string
  nullable = false

  validation {
    condition     = can(index(["Server", "ECS", "Lambda"], var.compute_platform))
    error_message = "Only Server / ECS / Lambda is supported"
  }
}

variable "deployment_config_name" {
  type     = string
  nullable = false
}

variable "service_role_name" {
  type     = string
  nullable = false
}

variable "use_blue_green" {
  type    = bool
  default = true

  validation {
    condition     = var.compute_platform != "Server" || var.use_blue_green
    error_message = "In-place deployment is only available on the EC2/On-Premises compute platform"
  }
}

variable "blue_green_deployment_config" {
  type = object({
    deployment_ready_option = optional(object({
      action_on_timeout    = optional(string, "CONTINUE_DEPLOYMENT")
      wait_time_in_minutes = optional(number)
    }), {})
    green_fleet_provisioning_option = optional(object({
      action = optional(string)
    }), {})
    terminate_blue_instances_on_deployment_success = optional(object({
      action                           = optional(string, "TERMINATE")
      termination_wait_time_in_minutes = optional(number, 0)
    }), {})
  })
  default = {}

  validation {
    condition     = can(index(["CONTINUE_DEPLOYMENT", "STOP_DEPLOYMENT"], var.blue_green_deployment_config.deployment_ready_option.action_on_timeout))
    error_message = "Only CONTINUE_DEPLOYMENT / STOP_DEPLOYMENT is supported"
  }

  validation {
    condition     = var.blue_green_deployment_config.deployment_ready_option.action_on_timeout != "STOP_DEPLOYMENT" || var.blue_green_deployment_config.deployment_ready_option.wait_time_in_minutes != null
    error_message = "deployment_ready_option.wait_time_in_minutes can not be null if STOP_DEPLOYMENT is selected"
  }

  validation {
    condition     = var.compute_platform != "Server" || !var.use_blue_green || var.blue_green_deployment_config.green_fleet_provisioning_option.action == null
    error_message = "green_fleet_provisioning_option.action can not be null if on the EC2/On-Premises compute platform with blue/green deployment"
  }

  validation {
    condition     = var.blue_green_deployment_config.green_fleet_provisioning_option.action == null || can(index(["DISCOVER_EXISTING", "COPY_AUTO_SCALING_GROUP"], var.blue_green_deployment_config.green_fleet_provisioning_option.action))
    error_message = "Only DISCOVER_EXISTING / COPY_AUTO_SCALING_GROUP is supported"
  }

  validation {
    condition     = can(index(["TERMINATE", "KEEP_ALIVE"], var.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.action))
    error_message = "Only TERMINATE / KEEP_ALIVE is supported"
  }

  validation {
    condition     = var.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.action != "TERMINATE" || var.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.termination_wait_time_in_minutes != null
    error_message = "terminate_blue_instances_on_deployment_success.wait_time_in_minutes can not be null if TERMINATE is selected"
  }
}

variable "alarms" {
  type    = list(string)
  default = []
}

variable "use_rollback" {
  type    = bool
  default = false
}

variable "rollback_events" {
  type    = list(string)
  default = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
}

variable "ec2" {
  type = object({
    autoscaling_groups = optional(list(string), [])
    tag_filters = optional(list(object({
      type  = optional(string)
      key   = optional(string)
      value = optional(string)
    })), [])
  })
  default = {}
}

variable "ecs_service" {
  type = object({
    cluster_name = optional(string)
    service_name = optional(string)
  })
  default = {}
}

variable "load_balancer" {
  type = object({
    prod_listener_arn  = optional(string)
    test_listener_arn  = optional(string)
    target_group_names = optional(list(string), [])
  })
  default = null
}