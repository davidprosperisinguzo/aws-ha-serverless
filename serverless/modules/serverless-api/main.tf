# Lambda execution role for API function
resource "aws_iam_role" "api_lambda_role" {
  name = "${var.name_prefix}-api-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-lambda-role"
  })
}

# IAM Policy for API Lambda - DynamoDB read, CloudWatch Logs
resource "aws_iam_policy" "api_lambda_policy" {
  name        = "${var.name_prefix}-api-lambda-policy"
  description = "Policy for API Lambda: DynamoDB read, CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBReadAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arn
      },
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-api:*"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "api_lambda_policy_attachment" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = aws_iam_policy.api_lambda_policy.arn
}

# AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "api_lambda_basic_execution" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function for API
resource "aws_lambda_function" "api" {
  function_name = "${var.name_prefix}-api"
  runtime       = var.lambda_runtime
  handler       = "api.lambda_handler"
  role          = aws_iam_role.api_lambda_role.arn
  filename      = data.archive_file.api_lambda_zip.output_path
  source_code_hash = data.archive_file.api_lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }

  timeout = 30

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api"
  })
}

# Archive the Lambda function code
data "archive_file" "api_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/api"
  output_path = "${path.module}/../../lambda/api/api.zip"
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.name_prefix}-http-api"
  protocol_type = "HTTP"
  description   = "HTTP API for file metadata"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-http-api"
  })
}

# Lambda integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api.arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "files_list" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /files"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "files_get" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /files/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-default-stage"
  })
}

# Lambda permission for API Gateway to invoke
resource "aws_lambda_permission" "apigw_invoke_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.arn}/*/*"
}