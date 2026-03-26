output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN — used when wiring up API Gateway."
  value       = aws_lambda_function.this.invoke_arn
}

output "execution_role_arn" {
  description = "ARN of the IAM execution role attached to the Lambda."
  value       = aws_iam_role.lambda_exec.arn
}

output "execution_role_name" {
  description = "Name of the IAM execution role — useful for attaching additional policies."
  value       = aws_iam_role.lambda_exec.name
}

output "log_group_name" {
  description = "CloudWatch Log Group name for this Lambda."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "CloudWatch Log Group ARN."
  value       = aws_cloudwatch_log_group.lambda.arn
}
