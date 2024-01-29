output "sns_payment_processing_topic_arn" {
  value = aws_sns_topic.payment_status_topic.arn
}

output "sns_inventory_topic_arn" {
  value = aws_sns_topic.inventory_status_topic.arn
}
