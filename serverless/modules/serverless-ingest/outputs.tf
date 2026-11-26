output "ingest_lambda_function_name" {
  description = "Name of the ingest Lambda function"
  value       = aws_lambda_function.ingest.function_name
}

output "ingest_lambda_function_arn" {
  description = "ARN of the ingest Lambda function"
  value       = aws_lambda_function.ingest.arn
}

output "ingest_lambda_role_arn" {
  description = "ARN of the ingest Lambda execution role"
  value       = aws_iam_role.ingest_lambda_role.arn
}