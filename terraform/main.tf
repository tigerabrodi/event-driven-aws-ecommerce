terraform {

  cloud {
    organization = "tiger_projects"
    workspaces {
      name = "event-driven-aws-ecommerce"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}
