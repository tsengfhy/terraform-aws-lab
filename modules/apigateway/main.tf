module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_api_gateway_rest_api" "this" {
  name = "${module.context.prefix}-apigateway-${var.name}"

  endpoint_configuration {
    types            = [var.type]
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }

  body                         = var.body
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  api_key_source               = var.api_key_source
  minimum_compression_size     = var.minimum_compression_size
  binary_media_types           = var.binary_media_types
  parameters                   = var.parameters
  fail_on_warnings             = true

  tags = module.context.tags
}

resource "aws_api_gateway_rest_api_policy" "test" {
  count = var.policy != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = var.policy
}