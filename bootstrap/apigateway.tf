resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = module.role_apigateway.arn
}

module "role_apigateway" {
  source = "../modules/iam/role"

  workspace = local.workspace

  name        = "AWSAPIGatewayAccountManagementRole"
  description = "AWS APIGateway Account Management Role"

  is_service_linked  = true
  assume_role_policy = data.aws_iam_policy_document.assume["apigateway"].json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs",
  ]
}