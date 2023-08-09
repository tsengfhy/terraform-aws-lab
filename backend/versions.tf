terraform {
  backend "s3" {
    key = "backend/terraform.tfstate"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    local = {
      source = "hashicorp/local"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}