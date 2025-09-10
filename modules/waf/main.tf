module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_wafv2_web_acl" "this" {
  name  = local.name
  scope = var.scope

  dynamic "rule" {
    for_each = concat(var.managed_rule_groups, var.rule_groups)

    content {
      name     = rule.value.name
      priority = rule.value.priority

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = can(rule.value.statement["name"]) ? [0] : []

          content {
            name        = rule.value.statement["name"]
            vendor_name = rule.value.statement["vendor_name"]
            version     = rule.value.statement["version"]

            dynamic "rule_action_override" {
              for_each = rule.value.statement["rule_action_overrides"]

              content {
                name = rule_action_override.value

                action_to_use {
                  count {}
                }
              }
            }
          }
        }

        dynamic "rule_group_reference_statement" {
          for_each = can(rule.value.statement["arn"]) ? [0] : []

          content {
            arn = rule.value.statement["arn"]

            dynamic "rule_action_override" {
              for_each = rule.value.statement["rule_action_overrides"]

              content {
                name = rule_action_override.value

                action_to_use {
                  count {}
                }
              }
            }
          }
        }
      }

      override_action {
        dynamic "count" {
          for_each = rule.value.use_override_action ? [0] : []
          content {}
        }

        dynamic "none" {
          for_each = !rule.value.use_override_action ? [0] : []
          content {}
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.use_metrics
        metric_name                = "${local.name}-${rule.value.name}"
        sampled_requests_enabled   = rule.value.use_sampled_requests
      }
    }
  }

  dynamic "rule" {
    for_each = var.rate_based_rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      statement {
        rate_based_statement {
          limit                 = rule.value.statement.limit
          evaluation_window_sec = rule.value.statement.evaluation_window_sec
          aggregate_key_type    = rule.value.statement.aggregate_key_type

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" && rule.value.statement.custom_key.ip != null ? [rule.value.statement.custom_key.ip] : []

            content {
              ip {}
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" && rule.value.statement.custom_key.forwarded_ip != null ? [rule.value.statement.custom_key.forwarded_ip] : []

            content {
              forwarded_ip {}
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" && rule.value.statement.custom_key.http_method != null ? [rule.value.statement.custom_key.http_method] : []

            content {
              http_method {}
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" && rule.value.statement.custom_key.uri_path != null ? [rule.value.statement.custom_key.uri_path] : []

            content {
              uri_path {
                dynamic "text_transformation" {
                  for_each = custom_key.value["text_transformations"]

                  content {
                    priority = text_transformation.value["priority"]
                    type     = text_transformation.value["type"]
                  }
                }
              }
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" && rule.value.statement.custom_key.query_string != null ? [rule.value.statement.custom_key.query_string] : []

            content {
              query_string {
                dynamic "text_transformation" {
                  for_each = custom_key.value["text_transformations"]

                  content {
                    priority = text_transformation.value["priority"]
                    type     = text_transformation.value["type"]
                  }
                }
              }
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" ? rule.value.statement.custom_key.query_arguments : []

            content {
              query_argument {
                name = custom_key.value["name"]

                dynamic "text_transformation" {
                  for_each = custom_key.value["text_transformations"]

                  content {
                    priority = text_transformation.value["priority"]
                    type     = text_transformation.value["type"]
                  }
                }
              }
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" ? rule.value.statement.custom_key.headers : []

            content {
              header {
                name = custom_key.value["name"]

                dynamic "text_transformation" {
                  for_each = custom_key.value["text_transformations"]

                  content {
                    priority = text_transformation.value["priority"]
                    type     = text_transformation.value["type"]
                  }
                }
              }
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" ? rule.value.statement.custom_key.headers : []

            content {
              header {
                name = custom_key.value["name"]

                dynamic "text_transformation" {
                  for_each = custom_key.value["text_transformations"]

                  content {
                    priority = text_transformation.value["priority"]
                    type     = text_transformation.value["type"]
                  }
                }
              }
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" ? rule.value.statement.custom_key.cookies : []

            content {
              cookie {
                name = custom_key.value["name"]

                dynamic "text_transformation" {
                  for_each = custom_key.value["text_transformations"]

                  content {
                    priority = text_transformation.value["priority"]
                    type     = text_transformation.value["type"]
                  }
                }
              }
            }
          }

          dynamic "custom_key" {
            for_each = rule.value.statement.aggregate_key_type == "CUSTOM_KEYS" ? rule.value.statement.custom_key.label_namespaces : []

            content {
              label_namespace {
                namespace = custom_key.value
              }
            }
          }

          dynamic "forwarded_ip_config" {
            for_each = rule.value.statement.forwarded_ip_config != null ? [rule.value.statement.forwarded_ip_config] : []

            content {
              header_name       = forwarded_ip_config.value["header_name"]
              fallback_behavior = forwarded_ip_config.value["fallback_behavior"]
            }
          }
        }
      }

      action {
        dynamic "block" {
          for_each = rule.value.action.type == "BLOCK" ? [rule.value.action] : []

          content {
            dynamic "custom_response" {
              for_each = block.value["response_code"] != null ? [0] : []

              content {
                response_code            = block.value["response_code"]
                custom_response_body_key = block.value["repsonse_body_key"]

                dynamic "response_header" {
                  for_each = block.value["response_headers"]

                  content {
                    name  = response_header.key
                    value = response_header.value
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = rule.value.action.type == "COUNT" ? [rule.value.action] : []

          content {
            dynamic "custom_request_handling" {
              for_each = length(count.value["request_headers"]) > 0 ? [0] : []

              content {
                dynamic "insert_header" {
                  for_each = count.value["request_headers"]

                  content {
                    name  = insert_header.key
                    value = insert_header.value
                  }
                }
              }
            }
          }
        }

        dynamic "captcha" {
          for_each = rule.value.action.type == "CAPTCHA" ? [rule.value.action] : []

          content {
            dynamic "custom_request_handling" {
              for_each = length(captcha.value["request_headers"]) > 0 ? [0] : []

              content {
                dynamic "insert_header" {
                  for_each = captcha.value["request_headers"]

                  content {
                    name  = insert_header.key
                    value = insert_header.value
                  }
                }
              }
            }
          }
        }

        dynamic "challenge" {
          for_each = rule.value.action.type == "CHALLENGE" ? [rule.value.action] : []

          content {
            dynamic "custom_request_handling" {
              for_each = length(challenge.value["request_headers"]) > 0 ? [0] : []

              content {
                dynamic "insert_header" {
                  for_each = challenge.value["request_headers"]

                  content {
                    name  = insert_header.key
                    value = insert_header.value
                  }
                }
              }
            }
          }
        }
      }

      dynamic "rule_label" {
        for_each = rule.value.rule_labels

        content {
          name = rule_label.value
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.use_metrics
        metric_name                = "${local.name}-${rule.value.name}"
        sampled_requests_enabled   = rule.value.use_sampled_requests
      }
    }
  }

  default_action {
    dynamic "allow" {
      for_each = var.default_action.type == "ALLOW" ? [var.default_action] : []

      content {
        dynamic "custom_request_handling" {
          for_each = length(allow.value["request_headers"]) > 0 ? [0] : []

          content {
            dynamic "insert_header" {
              for_each = allow.value["request_headers"]

              content {
                name  = insert_header.key
                value = insert_header.value
              }
            }
          }
        }
      }
    }

    dynamic "block" {
      for_each = var.default_action.type == "BLOCK" ? [var.default_action] : []

      content {
        dynamic "custom_response" {
          for_each = block.value["response_code"] != null ? [0] : []

          content {
            response_code            = block.value["response_code"]
            custom_response_body_key = block.value["repsonse_body_key"]

            dynamic "response_header" {
              for_each = block.value["response_headers"]

              content {
                name  = response_header.key
                value = response_header.value
              }
            }
          }
        }
      }
    }
  }

  dynamic "custom_response_body" {
    for_each = var.response_bodies

    content {
      key          = custom_response_body.value.key
      content_type = custom_response_body.value.content_type
      content      = custom_response_body.value.content
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.use_metrics
    metric_name                = local.name
    sampled_requests_enabled   = var.use_sampled_requests
  }

  tags = module.context.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.use_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [one(aws_cloudwatch_log_group.this).arn]

  dynamic "redacted_fields" {
    for_each = var.logging_config.redacted_headers

    content {
      single_header {
        name = redacted_fields.value
      }
    }
  }

  dynamic "logging_filter" {
    for_each = var.logging_config.filter != null ? [var.logging_config.filter] : []

    content {
      default_behavior = logging_filter.value["default_behavior"]

      filter {
        behavior    = logging_filter.value["behavior"]
        requirement = logging_filter.value["requirement"]

        dynamic "condition" {
          for_each = logging_filter.value["condition"]

          content {
            dynamic "action_condition" {
              for_each = condition.value["action"] != null ? [condition.value["action"]] : []

              content {
                action = action_condition.value
              }
            }

            dynamic "label_name_condition" {
              for_each = condition.value["label_name"] != null ? [condition.value["label_name"]] : []

              content {
                label_name = label_name_condition.value
              }
            }
          }
        }
      }
    }
  }
}