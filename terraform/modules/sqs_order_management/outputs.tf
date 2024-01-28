
output "sqs_order_management_queue_url" {
  value = aws_sqs_queue.order_queue.url
}

output "sqs_order_management_queue_arn" {
  value = aws_sqs_queue.order_queue.arn

}
