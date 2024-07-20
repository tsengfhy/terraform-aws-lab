module "context" {
  source = "../context"

  workspace = var.workspace
}

resource "aws_lb" "this" {
  name               = "${module.context.prefix}-elb-${var.name}"
  load_balancer_type = var.type
  internal           = var.internal
  ip_address_type    = var.use_ipv6 ? "dualstack" : "ipv4"
  subnets            = [for key, value in data.aws_subnet.selected : value.id]
  security_groups    = [aws_security_group.this.id]

  idle_timeout = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.use_logging ? [0] : []

    content {
      enabled = true
      bucket  = one(data.aws_s3_bucket.log).bucket
    }
  }

  tags = module.context.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = local.protocol
  port              = local.port
  certificate_arn   = var.use_dns ? one(data.aws_acm_certificate.selected).arn : null
  alpn_policy       = local.protocol == "TLS" ? "HTTP2Preferred" : null

  dynamic "default_action" {
    for_each = var.action.type == "forward" ? [0] : []

    content {
      type             = "forward"
      target_group_arn = var.action.target_group_arn
    }
  }

  dynamic "default_action" {
    for_each = var.action.type == "redirect" ? [0] : []

    content {
      type = "redirect"

      redirect {
        status_code = var.action.status_code
        protocol    = var.action.protocol
        host        = var.action.host
        port        = var.action.port
        path        = var.action.path
        query       = var.action.query
      }
    }
  }

  dynamic "default_action" {
    for_each = var.action.type == "fixed-response" ? [0] : []

    content {
      type = "fixed-response"

      fixed_response {
        status_code  = var.action.status_code
        content_type = var.action.content_type
        message_body = var.action.message_body
      }
    }
  }

  tags = module.context.tags
}