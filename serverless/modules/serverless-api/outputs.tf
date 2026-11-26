output "api_lambda_function_name" {
  description = "Name of the API Lambda function"
  value       = aws_lambda_function.api.function_name
}

output "api_lambda_function_arn" {
  description = "ARN of the API Lambda function"
  value       = aws_lambda_function.api.arn
}

output "api_lambda_role_arn" {
  description = "ARN of the API Lambda execution role"
  value       = aws_iam_role.api_lambda_role.arn
}

output "http_api_id" {
  description = "ID of the HTTP API"
  value       = aws_apigatewayv2_api.http_api.id
}

output "http_api_endpoint" {
  description = "Endpoint URL of the HTTP API"
  value       = aws_apigatewayv2_stage.default.invoke_url
}