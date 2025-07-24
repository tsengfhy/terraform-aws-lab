output "name" {
  value = aws_ecs_service.this.name
}

output "arn" {
  value = aws_ecs_service.this.arn
}

output "task_definition_name" {
  value = aws_ecs_task_definition.this.family
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "autoscaling_target_id" {
  value = aws_appautoscaling_target.this.id
}

output "target_group_names" {
  value = [for target_group in values(aws_lb_target_group.this) : target_group.name]
}