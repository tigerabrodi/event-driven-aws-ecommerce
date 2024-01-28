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

module "sqs_order_management" {
  source = "./modules/sqs_order_management"
}

module "sns_topics" {
  source = "./modules/sns_topics"
}

module "order_management_lambda" {
  source        = "./modules/order_management_lambda"
  sqs_queue_arn = module.sqs_order_management.sqs_order_management_queue_arn
  sqs_queue_url = module.sqs_order_management.sqs_order_management_queue_url
}
