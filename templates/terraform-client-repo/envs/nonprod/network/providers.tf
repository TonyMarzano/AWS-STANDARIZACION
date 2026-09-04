terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Cliente     = var.cliente
      Environment = "nonprod"
      Owner       = "cloud-ops@bghtechpartner.com"
    }
  }
}
