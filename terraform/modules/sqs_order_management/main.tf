resource "aws_sqs_queue" "order_queue" {

  name = "order_queue"

  delay_seconds = 0 // messages are delivered immediately

  max_message_size = 1024 // 1024 KB, minimum value

  message_retention_seconds = 345600 // 4 days

  visibility_timeout_seconds = 30 // The time during which the queue prevents other consumers from receiving and processing the message

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_queue_dead_letter.arn
    maxReceiveCount     = 4 // how many times a message can be received and processed before being sent to the dead letter queue
  })
}

resource "aws_sqs_queue" "order_queue_dead_letter" {
  name = "order_queue_dead_letter"
}
