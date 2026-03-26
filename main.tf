terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# ──────────────────────────────────────────
# IAM Role for Lambda Execution
# ──────────────────────────────────────────

resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "${var.function_name}-exec-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
        }
      ],
      var.ssm_parameter_arns != [] ? [{
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = var.ssm_parameter_arns
      }] : [],
      var.additional_policy_statements
    )
  })
}

# ──────────────────────────────────────────
# CloudWatch Log Group
# ──────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# ──────────────────────────────────────────
# Lambda Function
# ──────────────────────────────────────────

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = aws_iam_role.lambda_exec.arn

  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.lambda_exec_policy
  ]

  tags = local.common_tags
}

# ──────────────────────────────────────────
# Optional: SNS Trigger
# ──────────────────────────────────────────

resource "aws_sns_topic_subscription" "trigger" {
  count = var.sns_topic_arn != null ? 1 : 0

  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "sns" {
  count = var.sns_topic_arn != null ? 1 : 0

  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

# ──────────────────────────────────────────
# Optional: S3 Trigger
# ──────────────────────────────────────────

resource "aws_s3_bucket_notification" "trigger" {
  count = var.s3_trigger_bucket != null ? 1 : 0

  bucket = var.s3_trigger_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = var.s3_trigger_events
    filter_prefix       = var.s3_trigger_prefix
    filter_suffix       = var.s3_trigger_suffix
  }

  depends_on = [aws_lambda_permission.s3]
}

resource "aws_lambda_permission" "s3" {
  count = var.s3_trigger_bucket != null ? 1 : 0

  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_trigger_bucket}"
}

# ──────────────────────────────────────────
# Locals
# ──────────────────────────────────────────

locals {
  common_tags = merge(
    {
      Name        = var.function_name
      Environment = var.environment
      Project     = var.project
      Owner       = var.owner
      ManagedBy   = "terraform"
    },
    var.additional_tags
  )
}
