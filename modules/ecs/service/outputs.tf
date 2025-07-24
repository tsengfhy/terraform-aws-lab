output "name" {
  value = aws_ecs_service.this.name
}

output "arn" {
  value = aws_ecs_service.this.arn
}

output "autoscaling_target_id" {
  value = aws_appautoscaling_target.this.id
}