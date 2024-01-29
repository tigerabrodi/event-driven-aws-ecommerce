resource "aws_lambda_function" "notification_service" {
  function_name = "notificationService"
  handler       = "notificationServiceHandler.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_iam_role.arn
  filename      = "${path.module}/notificationService.zip"

  source_code_hash = filebase64sha256("${path.module}/notificationService.zip")
  environment {
    variables = {
      SENDER_EMAIL = var.sender_email
    }
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_notification_service_role"
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

resource "aws_iam_role_policy" "lambda_ses_policy" {
  name = "lambda_ses_policy"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ses:SendEmail"
        ],
        Effect   = "Allow",
        Resource = "*"
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

resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = var.sns_inventory_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notification_service.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_service.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_inventory_topic_arn
}

resource "aws_ses_email_identity" "email_identity" {
  email = var.sender_email
}

resource "aws_ses_identity_policy" "email_identity_policy" {
  identity = aws_ses_email_identity.email_identity.arn
  name     = "email_identity_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Effect   = "Allow",
        Resource = aws_ses_email_identity.email_identity.arn,
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        }
      },
    ],
  })
}
