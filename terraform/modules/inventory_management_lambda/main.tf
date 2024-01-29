
resource "aws_lambda_function" "inventory_management" {
  function_name = "inventoryManagement"
  handler       = "inventoryManagementHandler.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_iam_role.arn
  filename      = "${path.module}/inventoryManagement.zip"

  source_code_hash = filebase64sha256("${path.module}/inventoryManagement.zip")
  environment {
    variables = {
      SNS_INVENTORY_TOPIC_ARN = var.sns_inventory_topic_arn
    }
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_inventory_management_role"
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

resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda_sns_policy"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sns:Publish"
        ],
        Effect   = "Allow",
        Resource = var.sns_inventory_topic_arn
      },
      {
        Action = [
          "sns:Subscribe"
        ],
        Effect   = "Allow",
        Resource = var.sns_payment_topic_arn
      },
    ],
  })
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = var.sns_payment_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.inventory_management.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inventory_management.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_payment_topic_arn
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

resource "aws_cloudwatch_log_group" "inventory_management_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.inventory_management.function_name}"
  retention_in_days = 7
}
