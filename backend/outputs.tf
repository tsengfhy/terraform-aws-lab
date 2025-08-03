output "region" {
  value = data.aws_region.current.region
}

output "bucket" {
  value = module.backend.id
}