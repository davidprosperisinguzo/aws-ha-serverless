# Lambda execution role for ingest function
resource "aws_iam_role" "ingest_lambda_role" {
  name = "${var.name_prefix}-ingest-lambda-role"

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
    Name = "${var.name_prefix}-ingest-lambda-role"
  })
}

# IAM Policy for ingest Lambda - S3 read, DynamoDB write, CloudWatch Logs
resource "aws_iam_policy" "ingest_lambda_policy" {
  name        = "${var.name_prefix}-ingest-lambda-policy"
  description = "Policy for ingest Lambda: S3 read, DynamoDB write, CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:HeadObject"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Sid    = "DynamoDBWriteAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
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
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-ingest:*"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ingest_lambda_policy_attachment" {
  role       = aws_iam_role.ingest_lambda_role.name
  policy_arn = aws_iam_policy.ingest_lambda_policy.arn
}

# AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "ingest_lambda_basic_execution" {
  role       = aws_iam_role.ingest_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function for ingest
resource "aws_lambda_function" "ingest" {
  function_name = "${var.name_prefix}-ingest"
  runtime       = var.lambda_runtime
  handler       = "ingest.lambda_handler"
  role          = aws_iam_role.ingest_lambda_role.arn
  filename      = data.archive_file.ingest_lambda_zip.output_path
  source_code_hash = data.archive_file.ingest_lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }

  timeout = 60

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ingest"
  })
}

# Archive the Lambda function code
data "archive_file" "ingest_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/ingest"
  output_path = "${path.module}/../../lambda/ingest/ingest.zip"
}

# Lambda permission for S3 to invoke
resource "aws_lambda_permission" "s3_invoke_ingest" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

# S3 Event Notification for ObjectCreated
resource "aws_s3_bucket_notification" "ingest_notification" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.ingest.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.s3_invoke_ingest]
}