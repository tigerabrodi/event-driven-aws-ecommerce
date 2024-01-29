variable "sns_inventory_topic_arn" {
  description = "The ARN of the SNS topic for inventory updates"
  type        = string
}

variable "sns_payment_topic_arn" {
  description = "The ARN of the SNS topic for payment updates"
  type        = string
}
