module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_codedeploy_app" "this" {
  name             = "${module.context.prefix}-codebuild-${var.name}"
  compute_platform = var.compute_platform

  tags = module.context.tags
}

resource "aws_codedeploy_deployment_group" "this" {
  deployment_group_name  = "primary"
  app_name               = aws_codedeploy_app.this.name
  service_role_arn       = data.aws_iam_role.service.arn
  deployment_config_name = var.deployment_config_name

  deployment_style {
    deployment_type   = var.use_blue_green ? "BLUE_GREEN" : "IN_PLACE"
    deployment_option = var.use_blue_green || var.load_balancer != null ? "WITH_TRAFFIC_CONTROL" : "WITHOUT_TRAFFIC_CONTROL"
  }

  dynamic "blue_green_deployment_config" {
    for_each = var.compute_platform != "Lambda" && var.use_blue_green ? [0] : []

    content {
      deployment_ready_option {
        action_on_timeout    = var.blue_green_deployment_config.deployment_ready_option.action_on_timeout
        wait_time_in_minutes = var.blue_green_deployment_config.deployment_ready_option.wait_time_in_minutes
      }

      dynamic "green_fleet_provisioning_option" {
        for_each = var.blue_green_deployment_config.green_fleet_provisioning_option.action != null ? [0] : []

        content {
          action = var.blue_green_deployment_config.green_fleet_provisioning_option.action
        }
      }

      terminate_blue_instances_on_deployment_success {
        action                           = var.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.action
        termination_wait_time_in_minutes = var.blue_green_deployment_config.terminate_blue_instances_on_deployment_success.termination_wait_time_in_minutes
      }
    }
  }

  dynamic "alarm_configuration" {
    for_each = length(var.alarms) > 0 ? [0] : []

    content {
      alarms = var.alarms
    }
  }

  dynamic "auto_rollback_configuration" {
    for_each = var.use_rollback ? [0] : []

    content {
      enabled = var.use_rollback
      events  = var.rollback_events
    }
  }

  autoscaling_groups       = var.compute_platform == "Server" ? var.ec2.autoscaling_groups : null
  termination_hook_enabled = var.compute_platform == "Server" && length(var.ec2.autoscaling_groups) > 0

  dynamic "ec2_tag_filter" {
    for_each = var.compute_platform == "Server" ? var.ec2.tag_filters : []

    content {
      type  = ec2_tag_filter.value.type
      key   = ec2_tag_filter.value.key
      value = ec2_tag_filter.value.value
    }
  }

  dynamic "ecs_service" {
    for_each = var.compute_platform == "ECS" ? [0] : []

    content {
      cluster_name = var.ecs_service.cluster_name
      service_name = var.ecs_service.service_name
    }
  }

  dynamic "load_balancer_info" {
    for_each = var.compute_platform != "Lambda" && var.load_balancer != null ? [0] : []

    content {
      dynamic "target_group_info" {
        for_each = var.compute_platform == "Server" ? [0] : []

        content {
          name = one(var.load_balancer.target_group_names)
        }
      }

      dynamic "target_group_pair_info" {
        for_each = var.compute_platform == "ECS" ? [0] : []

        content {
          prod_traffic_route {
            listener_arns = [var.load_balancer.prod_listener_arn]
          }

          dynamic "test_traffic_route" {
            for_each = var.load_balancer.test_listener_arn != null ? [0] : []

            content {
              listener_arns = [var.load_balancer.test_listener_arn]
            }
          }

          dynamic "target_group" {
            for_each = var.load_balancer.target_group_names

            content {
              name = target_group.value
            }
          }
        }
      }
    }
  }

  tags = module.context.tags
}