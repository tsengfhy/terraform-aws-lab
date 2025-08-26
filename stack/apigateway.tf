module "apigateway" {
  for_each = var.apis
  source   = "../modules/apigateway"

  workspace = local.workspace

  name = each.key
  type = "REGIONAL"

  body = templatefile("${path.module}/tests/apigateway/${each.key}.yml", merge(
    each.value.use_function ? {
      uri = module.lambda[each.key].invoke_arn
    } : {}
  ))

  disable_execute_api_endpoint = var.domain != null
}

# resource "aws_api_gateway_resource" "this" {
#   for_each = var.apis
#
#   rest_api_id = module.apigateway[each.key].id
#   parent_id   = module.apigateway[each.key].root_resource_id
#   path_part   = "{proxy+}"
# }
#
# resource "aws_api_gateway_method" "this" {
#   for_each = var.apis
#
#   rest_api_id = module.apigateway[each.key].id
#   resource_id = aws_api_gateway_resource.this[each.key].id
#   http_method = "ANY"
#
#   authorization = "NONE"
#   request_parameters = {
#     "method.request.path.proxy" = true
#   }
# }
#
# resource "aws_api_gateway_integration" "this" {
#   for_each = var.apis
#
#   rest_api_id = module.apigateway[each.key].id
#   resource_id = aws_api_gateway_resource.this[each.key].id
#   http_method = aws_api_gateway_method.this[each.key].http_method
#
#   type                    = "AWS_PROXY"
#   integration_http_method = "POST"
#   uri                     = module.lambda[each.key].invoke_arn
#   timeout_milliseconds    = 29000
# }

resource "aws_api_gateway_deployment" "this" {
  for_each = var.apis

  rest_api_id = module.apigateway[each.key].id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      # aws_api_gateway_resource.this[each.key],
      # aws_api_gateway_method.this[each.key],
      # aws_api_gateway_integration.this[each.key],
      module.apigateway[each.key].body,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "stage" {
  for_each = var.apis
  source   = "../modules/apigateway/stage"

  workspace = local.workspace

  name          = local.workspace
  rest_api_id   = module.apigateway[each.key].id
  deployment_id = aws_api_gateway_deployment.this[each.key].id

  domain_name = module.domain[each.key].name
}

module "domain" {
  for_each = var.apis
  source   = "../modules/apigateway/domain"

  workspace = local.workspace

  domain = var.domain
  alias  = each.value.alias
  type   = "REGIONAL"

  use_dns = true

  providers = {
    aws.global = aws.global
  }
}

module "lambda" {
  for_each = { for key, value in var.apis : key => value if value.use_function }
  source   = "../modules/lambda"

  workspace = local.workspace

  name     = "apigateway-${each.key}"
  filename = data.archive_file.lambda[each.key].output_path
  runtime  = "nodejs22.x"
  handler  = "index.handler"
}

resource "aws_lambda_permission" "this" {
  for_each = { for key, value in var.apis : key => value if value.use_function }

  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda[each.key].id
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.apigateway[each.key].execution_arn}/*"
}

data "archive_file" "lambda" {
  for_each = { for key, value in var.apis : key => value if value.use_function }

  type        = "zip"
  source_file = "${path.module}/tests/lambda/${each.key}.mjs"
  output_path = "${path.module}/tests/lambda/${each.key}.zip"
}