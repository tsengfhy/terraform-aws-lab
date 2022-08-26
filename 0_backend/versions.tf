terraform {
  backend "s3" {
    key = "backend/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    local = {
      source = "hashicorp/local"
    }
  }

  required_version = "~> 1.1.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}