resource "aws_lb_listener_rule" "this" {
  listener_arn = one(data.aws_lb_listener.selected).arn
  priority     = var.priority

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }

  action {
    type             = "forward"
    target_group_arn = one(aws_lb_target_group.this).arn
  }
}

resource "aws_lb_target_group" "this" {
  count = var.use_lb ? 1 : 0

  name        = "${module.context.prefix}-tg-ecs-service-${var.name}"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "ip"
  protocol    = "HTTP"
  port        = var.container_port

  health_check {
    enabled = true
    path    = var.health_check
    matcher = "200-399"
  }

  stickiness {
    enabled = var.stickiness
    type    = "lb_cookie"
  }

  tags = module.context.tags
}