resource "aws_cloudtrail" "default" {
  name           = "${module.context.prefix}-trail-default"
  s3_bucket_name = split(":", module.log.arn)[5]

  enable_logging                = true
  is_multi_region_trail         = false
  include_global_service_events = true

  event_selector {
    include_management_events = true
    read_write_type           = "WriteOnly"
  }

  tags = module.context.tags
}
