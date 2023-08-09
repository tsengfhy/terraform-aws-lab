resource "aws_lb" "this" {
  name               = "${module.context.prefix}-alb-ecs"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  subnets            = data.aws_subnet_ids.public.ids
  security_groups    = [aws_security_group.alb.id]

  dynamic "access_logs" {
    for_each = var.log_bucket_name != null ? [0] : []
    content {
      enabled = true
      bucket  = one(data.aws_s3_bucket.log).bucket
      prefix  = "${module.context.prefix}-ecs-alb/"
    }
  }

  tags = module.context.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.id
  protocol          = "HTTP"
  port              = local.alb_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = module.context.tags
}

resource "aws_lb_target_group" "this" {
  name        = "${module.context.prefix}-tg-ecs"
  vpc_id      = data.aws_vpc.selected.id
  protocol    = "HTTP"
  port        = var.task_container_port
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_security_group" "alb" {
  name        = "${module.context.prefix}-sg-alb"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol    = "tcp"
    from_port   = local.alb_port
    to_port     = local.alb_port
    cidr_blocks = [local.anywhere_cidr]
  }

  egress {
    protocol    = "tcp"
    from_port   = var.task_container_port
    to_port     = var.task_container_port
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  tags = module.context.tags
}