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

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ID of the application security group"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the EC2 instance profile"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the launch template (Amazon Linux 2023)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = 4
}

variable "ecr_account_id" {
  description = "AWS Account ID for ECR"
  type        = string
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "nodejs-cicd-app"
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}