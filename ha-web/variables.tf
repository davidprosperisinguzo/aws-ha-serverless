variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-ha-serverless"
}

variable "stack_name" {
  description = "Stack name used for resource naming"
  type        = string
  default     = "ha"
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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use (exactly 2 for HA)"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly 2 availability zones must be provided for HA architecture."
  }
}

variable "ami_id" {
  description = "AMI ID for the launch template (Amazon Linux 2023)"
  type        = string
  default     = "ami-0a3c3a20c09d6f377"
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