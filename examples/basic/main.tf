provider "aws" {
  region = "eu-west-2"
}

# Zip the Lambda function before applying
# zip lambda_function.zip lambda_function.py

module "hello_lambda" {
  source = "github.com/mifidon96/terraform-aws-lambda"

  function_name = "hello-world"
  description   = "Basic example Lambda deployed via the terraform-aws-lambda module."
  filename      = "${path.module}/lambda_function.zip"

  handler     = "lambda_function.lambda_handler"
  runtime     = "python3.11"
  timeout     = 30
  memory_size = 128

  environment_variables = {
    LOG_LEVEL = "INFO"
  }

  log_retention_days = 14

  environment = "dev"
  project     = "terraform-aws-lambda"
  owner       = "platform-team"
}

output "function_name" {
  value = module.hello_lambda.function_name
}

output "log_group" {
  value = module.hello_lambda.log_group_name
}
