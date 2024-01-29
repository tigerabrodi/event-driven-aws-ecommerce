terraform {

  cloud {
    organization = "{your-organization-name}"
    workspaces {
      name = "{your-workspace-name}"
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

module "payment_processing_lambda" {
  source        = "./modules/payment_processing_lambda"
  sns_topic_arn = module.sns_topics.sns_payment_processing_topic_arn
  sqs_queue_arn = module.sqs_order_management.sqs_order_management_queue_arn
}

module "inventory_management_lambda" {
  source                  = "./modules/inventory_management_lambda"
  sns_inventory_topic_arn = module.sns_topics.sns_inventory_topic_arn
  sns_payment_topic_arn   = module.sns_topics.sns_payment_processing_topic_arn
}

module "notification_service_lambda" {
  source                  = "./modules/notification_service_lambda"
  sender_email            = var.sender_email
  sns_inventory_topic_arn = module.sns_topics.sns_inventory_topic_arn
  user_name               = var.user_name
  account_id              = var.account_id
}
