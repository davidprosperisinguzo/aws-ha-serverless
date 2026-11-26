variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-ha-serverless"
}

variable "stack_name" {
  description = "Stack name used for resource naming"
  type        = string
  default     = "serverless"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-2"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix for globally unique S3 bucket name"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}