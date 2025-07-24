resource "aws_lb_listener_rule" "this" {
  count = var.use_lb ? 1 : 0

  listener_arn = one(data.aws_lb_listener.selected).arn
  priority     = var.priority

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this["blue"].arn
  }

  tags = module.context.tags

  lifecycle {
    ignore_changes = [action[0].target_group_arn]
  }
}

resource "aws_lb_target_group" "this" {
  for_each = var.use_lb ? var.use_codedeploy ? toset(["blue", "green"]) : toset(["blue"]) : []

  name        = "${module.context.prefix}-targetgroup-ecs-${var.name}${var.use_codedeploy ? "-${each.key}" : ""}"
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