# aws-ha-serverless

Multi-AZ web app with auto scaling, plus a serverless app on AWS.

## Folder Layout

- `ha-web/` - Multi-AZ highly available web application (VPC, ALB, Auto Scaling, NAT gateways)
- `serverless/` - S3-to-DynamoDB Lambda pipeline with HTTP API (API Gateway, 2 Python Lambdas)
