resource "aws_lambda_function" "payment_processing" {
  function_name = "paymentProcessing"
  handler       = "paymentProcessingHandler.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_iam_role.arn
  filename      = "${path.module}/paymentProcessing.zip"

  source_code_hash = filebase64sha256("${path.module}/paymentProcessing.zip")
  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_payment_processing_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "lambda_sqs_sns_policy" {
  name = "lambda_sqs_sns_policy"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sns:Publish"
        ],
        Effect = "Allow",
        Resource = [
          var.sqs_queue_arn,
          var.sns_topic_arn
        ]
      },
    ],
  })
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.payment_processing.arn
  batch_size       = 10
}

resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "lambda_cloudwatch_policy"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
    ],
  })
}

resource "aws_cloudwatch_log_group" "payment_processing_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.payment_processing.function_name}"
  retention_in_days = 7
}

