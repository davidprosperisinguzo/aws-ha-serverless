output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.serverless_storage.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.serverless_storage.s3_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.serverless_storage.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.serverless_storage.dynamodb_table_arn
}

output "ingest_lambda_function_name" {
  description = "Name of the ingest Lambda function"
  value       = module.serverless_ingest.ingest_lambda_function_name
}

output "api_lambda_function_name" {
  description = "Name of the API Lambda function"
  value       = module.serverless_api.api_lambda_function_name
}

output "http_api_endpoint" {
  description = "Endpoint URL of the HTTP API"
  value       = module.serverless_api.http_api_endpoint
}