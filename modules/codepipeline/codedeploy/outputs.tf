output "app_name" {
  value = aws_codedeploy_app.this.name
}

output "app_arn" {
  value = aws_codedeploy_app.this.arn
}

output "group_name" {
  value = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "group_arn" {
  value = aws_codedeploy_deployment_group.this.arn
}