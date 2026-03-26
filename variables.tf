# ──────────────────────────────────────────
# Required
# ──────────────────────────────────────────

variable "function_name" {
  description = "Name of the Lambda function. Used as a prefix for all associated resources."
  type        = string
}

variable "filename" {
  description = "Path to the zipped Lambda deployment package."
  type        = string
}

# ──────────────────────────────────────────
# Function Config
# ──────────────────────────────────────────

variable "description" {
  description = "Description of what the Lambda function does."
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda handler in the format filename.function_name."
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime. Defaults to Python 3.11."
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Lambda timeout in seconds. Max 900."
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda memory allocation in MB. Min 128, max 10240."
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda function."
  type        = map(string)
  default     = {}
}

# ──────────────────────────────────────────
# Logging
# ──────────────────────────────────────────

variable "log_retention_days" {
  description = "CloudWatch log retention period in days. Set explicitly to avoid infinite retention."
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch retention value."
  }
}

# ──────────────────────────────────────────
# IAM
# ──────────────────────────────────────────

variable "ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs the Lambda needs read access to."
  type        = list(string)
  default     = []
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements to attach to the Lambda execution role."
  type        = any
  default     = []
}

# ──────────────────────────────────────────
# Triggers
# ──────────────────────────────────────────

variable "sns_topic_arn" {
  description = "ARN of an SNS topic to trigger this Lambda. Leave null to skip."
  type        = string
  default     = null
}

variable "s3_trigger_bucket" {
  description = "Name of an S3 bucket to trigger this Lambda on object events. Leave null to skip."
  type        = string
  default     = null
}

variable "s3_trigger_events" {
  description = "S3 event types to trigger the Lambda."
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "s3_trigger_prefix" {
  description = "S3 key prefix filter for the trigger."
  type        = string
  default     = ""
}

variable "s3_trigger_suffix" {
  description = "S3 key suffix filter for the trigger (e.g. .json)."
  type        = string
  default     = ""
}

# ──────────────────────────────────────────
# Tagging
# ──────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
}

variable "project" {
  description = "Project name for tagging and cost allocation."
  type        = string
}

variable "owner" {
  description = "Owner of the resource — team or individual."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to merge into all resources."
  type        = map(string)
  default     = {}
}
