resource "aws_cloudtrail" "default" {
  name           = "${local.workspace}-trail-default"
  s3_bucket_name = data.aws_s3_bucket.log.id

  enable_logging                = true
  is_multi_region_trail         = false
  include_global_service_events = true

  event_selector {
    include_management_events = true
    read_write_type           = "WriteOnly"
  }
}
