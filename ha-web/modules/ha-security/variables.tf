variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "stack_name" {
  description = "Stack name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}