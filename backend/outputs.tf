output "region" {
  value = data.aws_region.current.name
}

output "bucket" {
  value = module.backend.id
}