create_bastion = false

domain = "tsengfhy.com"

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
  # }
}

pages = {
  # test = {
  #   alias = "page"
  # }
}

jobs = {
  # testJob = {
  #   schedule_expression = "cron(0 0 * * ? *)"
  # }
}

buckets = {
  default = {
    force_destroy = true
  }
}

queues = {
  default = {}
}