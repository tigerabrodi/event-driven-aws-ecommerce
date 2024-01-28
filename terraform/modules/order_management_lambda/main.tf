resource "aws_lambda_function" "order_management" {
  function_name = "orderManagement"
  handler       = "orderManagementHandler.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_iam_role.arn
  filename      = "${path.module}/orderManagement.zip"

  source_code_hash = filebase64sha256("${path.module}/orderManagement.zip")
  environment {
    variables = {
      SQS_QUEUE_URL = var.sqs_queue_url
    }
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_order_management_role"
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

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda_sqs_policy"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sqs:SendMessage"
        ],
        Effect   = "Allow",
        Resource = var.sqs_queue_arn
      },
    ],
  })
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

# CloudWatch Log Group to see logs from Lambda
resource "aws_cloudwatch_log_group" "order_management_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.order_management.function_name}"
  retention_in_days = 7
}
