resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.desired_count
  min_capacity       = var.desired_count
  resource_id        = "service/${data.aws_ecs_cluster.selected.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [
      max_capacity,
      min_capacity,
    ]
  }
}