# terraform-aws-lambda

A reusable Terraform module for deploying AWS Lambda functions with a production-ready baseline out of the box.

## What this provisions

- **Lambda function** — Python 3.11 runtime by default, fully configurable
- **IAM execution role** — least-privilege, scoped to only what the function needs
- **CloudWatch Log Group** — with explicit retention (no infinite log accumulation)
- **Optional SNS trigger** — subscribe the Lambda to an SNS topic
- **Optional S3 trigger** — invoke the Lambda on S3 object events

## Why these defaults matter

| Decision | Reason |
|---|---|
| Explicit log retention | Infinite retention is a common cost and compliance issue |
| IAM scoped to log group ARN | Avoids over-permissive `logs:*` on `*` |
| `depends_on` log group | Ensures the log group exists before first invocation |
| `source_code_hash` | Forces re-deploy when function code changes |
| Mandatory tagging | Enables cost allocation and resource governance |

## Usage

```hcl
module "my_lambda" {
  source = "github.com/your-username/terraform-aws-lambda"

  function_name = "my-function"
  filename      = "lambda_function.zip"

  environment = "prod"
  project     = "my-project"
  owner       = "platform-team"
}
```

## With SSM access

```hcl
module "my_lambda" {
  source = "github.com/your-username/terraform-aws-lambda"

  function_name = "my-function"
  filename      = "lambda_function.zip"

  ssm_parameter_arns = [
    "arn:aws:ssm:eu-west-2:123456789:parameter/my-app/db-password"
  ]

  environment = "prod"
  project     = "my-project"
  owner       = "platform-team"
}
```

## With S3 trigger

```hcl
module "my_lambda" {
  source = "github.com/your-username/terraform-aws-lambda"

  function_name     = "process-uploads"
  filename          = "lambda_function.zip"
  s3_trigger_bucket = "my-uploads-bucket"
  s3_trigger_suffix = ".json"

  environment = "prod"
  project     = "my-project"
  owner       = "platform-team"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `function_name` | Lambda function name | `string` | — | ✅ |
| `filename` | Path to zipped deployment package | `string` | — | ✅ |
| `environment` | Deployment environment (dev/staging/prod) | `string` | — | ✅ |
| `project` | Project name for tagging | `string` | — | ✅ |
| `owner` | Owning team or individual | `string` | — | ✅ |
| `handler` | Function handler | `string` | `lambda_function.lambda_handler` | ❌ |
| `runtime` | Lambda runtime | `string` | `python3.11` | ❌ |
| `timeout` | Timeout in seconds | `number` | `30` | ❌ |
| `memory_size` | Memory in MB | `number` | `128` | ❌ |
| `log_retention_days` | CloudWatch log retention | `number` | `14` | ❌ |
| `environment_variables` | Lambda env vars | `map(string)` | `{}` | ❌ |
| `ssm_parameter_arns` | SSM params to grant read access | `list(string)` | `[]` | ❌ |
| `sns_topic_arn` | SNS topic ARN for trigger | `string` | `null` | ❌ |
| `s3_trigger_bucket` | S3 bucket name for trigger | `string` | `null` | ❌ |
| `s3_trigger_events` | S3 event types | `list(string)` | `["s3:ObjectCreated:*"]` | ❌ |
| `additional_policy_statements` | Extra IAM policy statements | `any` | `[]` | ❌ |
| `additional_tags` | Extra resource tags | `map(string)` | `{}` | ❌ |

## Outputs

| Name | Description |
|---|---|
| `function_name` | Lambda function name |
| `function_arn` | Lambda function ARN |
| `invoke_arn` | Invoke ARN (for API Gateway) |
| `execution_role_arn` | IAM execution role ARN |
| `execution_role_name` | IAM execution role name |
| `log_group_name` | CloudWatch Log Group name |
| `log_group_arn` | CloudWatch Log Group ARN |

## Running the example

```bash
cd examples/basic
zip lambda_function.zip lambda_function.py
terraform init
terraform plan
```

## Requirements

| Tool | Version |
|---|---|
| Terraform | >= 1.3.0 |
| AWS Provider | >= 5.0.0 |
