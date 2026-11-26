output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.ingest_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.ingest_bucket.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.file_metadata.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.file_metadata.arn
}