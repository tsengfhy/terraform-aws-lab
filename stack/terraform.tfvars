create_bastion = false

domain = "tsengfhy.com"

notification_email_addresses = ["tsengfhy@gmail.com"]

apis = {
  # test = {
  #   alias = "api"
  # }
}

services = {
  # test = {
  #   container_port = 80
  #   path_pattern   = "/*"
  #   health_check   = "/index.html"
  #
  #   repo_name   = "tsengfhy/ecs"
  #   branch_name = "main"
  # }
}

pages = {
  # test = {
  #   alias = "page"
  # }
}

job_config = {
  repo_name   = "tsengfhy/batch"
  branch_name = "main"
}

jobs = {
  # testJob = {
  #   schedule_expression = "cron(0 0 * * ? *)"
  # }
}

buckets = {
  artifact = {
    force_destroy         = true
    use_default_lifecycle = true
  }
  default = {
    force_destroy = true
  }
}

queues = {
  default = {}
}

create_codepipeline = false
artifact_bucket_key = "artifact"