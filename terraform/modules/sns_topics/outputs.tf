output "sns_payment_processing_topic_arn" {
  value = aws_sns_topic.payment_status_topic.arn
}
