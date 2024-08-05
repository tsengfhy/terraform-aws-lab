module "context" {
  source = "../../context"

  workspace = var.workspace
}

resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = "${module.context.prefix}-configuration-set-${var.name}"

  delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = false
  }

  tags = module.context.tags
}

resource "aws_sesv2_configuration_set_event_destination" "this" {
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name
  event_destination_name = "default"

  event_destination {
    enabled              = true
    matching_event_types = var.matching_event_types

    sns_destination {
      topic_arn = module.sns.arn
    }
  }

  lifecycle {
    ignore_changes = [event_destination[0].enabled]
  }
}
