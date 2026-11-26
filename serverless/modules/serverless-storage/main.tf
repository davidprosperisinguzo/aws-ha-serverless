# S3 Bucket for file uploads
resource "aws_s3_bucket" "ingest_bucket" {
  bucket = "${var.name_prefix}-ingest-${var.unique_suffix}"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ingest"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "ingest_bucket_versioning" {
  bucket = aws_s3_bucket.ingest_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "ingest_bucket_encryption" {
  bucket = aws_s3_bucket.ingest_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Block Public Access
resource "aws_s3_bucket_public_access_block" "ingest_bucket_public_access" {
  bucket = aws_s3_bucket.ingest_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for file metadata
resource "aws_dynamodb_table" "file_metadata" {
  name           = "${var.name_prefix}-file-metadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "file_id"
  stream_enabled = false

  attribute {
    name = "file_id"
    type = "S"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-file-metadata"
  })
}