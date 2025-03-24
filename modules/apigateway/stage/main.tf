module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id = var.rest_api_id
  stage_name  = var.name

  deployment_id         = var.deployment_id
  documentation_version = var.documentation_version

  client_certificate_id = var.client_certificate_id
  variables             = var.variables

  cache_cluster_enabled = local.use_caching
  cache_cluster_size    = var.caching_settings.size

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      extendedRequestId = "$context.extendedRequestId"
      requestTime       = "$context.requestTime"

      protocol   = "$context.protocol"
      httpMethod = "$context.httpMethod"
      path       = "$context.path"

      userAgent = "$context.identity.userAgent"
      ip        = "$context.identity.sourceIp"
      caller    = "$context.identity.caller"
      user      = "$context.identity.user"

      integrationRequestId = "$context.integration.requestId"
      integrationStatus    = "$context.integration.status"
      integrationError     = "$context.integration.error"
      integrationLatency   = "$context.integration.latency"

      status          = "$context.status"
      responseLatency = "$context.responseLatency"
    })
  }

  tags = module.context.tags
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = var.rest_api_id
  stage_name  = aws_api_gateway_stage.this.stage_name

  method_path = "*/*"

  settings {
    caching_enabled                            = local.use_caching
    cache_data_encrypted                       = var.caching_settings.data_encrypted
    cache_ttl_in_seconds                       = var.caching_settings.ttl_in_seconds
    require_authorization_for_cache_control    = var.caching_settings.require_authorization_for_cache_control
    unauthorized_cache_control_header_strategy = var.caching_settings.unauthorized_cache_control_header_strategy

    throttling_rate_limit  = var.throttling_settings.rate_limit
    throttling_burst_limit = var.throttling_settings.burst_limit

    logging_level      = var.logging_settings.level
    data_trace_enabled = var.logging_settings.data_trace_enabled
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count = var.domain_name != null ? 1 : 0

  api_id     = var.rest_api_id
  stage_name = aws_api_gateway_stage.this.stage_name

  domain_name = var.domain_name
  base_path   = var.base_path
}