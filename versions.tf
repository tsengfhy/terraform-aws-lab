terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    key = "lab/terraform.tfstate"
  }

  required_version = "~> 1.1.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}