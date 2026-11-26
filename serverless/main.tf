module "serverless_storage" {
  source = "./modules/serverless-storage"

  project_name  = var.project_name
  stack_name    = var.stack_name
  environment   = var.environment
  common_tags   = local.common_tags
  name_prefix   = local.name_prefix
  unique_suffix = var.unique_suffix
}

module "serverless_ingest" {
  source = "./modules/serverless-ingest"

  project_name        = var.project_name
  stack_name          = var.stack_name
  environment         = var.environment
  aws_region          = var.aws_region
  aws_account_id      = var.aws_account_id
  s3_bucket_name      = module.serverless_storage.s3_bucket_name
  s3_bucket_arn       = module.serverless_storage.s3_bucket_arn
  dynamodb_table_name = module.serverless_storage.dynamodb_table_name
  dynamodb_table_arn  = module.serverless_storage.dynamodb_table_arn
  lambda_runtime      = var.lambda_runtime
  common_tags         = local.common_tags
  name_prefix         = local.name_prefix
}

module "serverless_api" {
  source = "./modules/serverless-api"

  project_name          = var.project_name
  stack_name            = var.stack_name
  environment           = var.environment
  aws_region            = var.aws_region
  aws_account_id        = var.aws_account_id
  dynamodb_table_name   = module.serverless_storage.dynamodb_table_name
  dynamodb_table_arn    = module.serverless_storage.dynamodb_table_arn
  lambda_runtime        = var.lambda_runtime
  common_tags           = local.common_tags
  name_prefix           = local.name_prefix
}