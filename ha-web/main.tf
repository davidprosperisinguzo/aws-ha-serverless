module "ha_vpc" {
  source = "./modules/ha-vpc"

  project_name       = var.project_name
  stack_name         = var.stack_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags        = local.common_tags
  name_prefix        = local.name_prefix
}

module "ha_security" {
  source = "./modules/ha-security"

  project_name = var.project_name
  stack_name   = var.stack_name
  environment  = var.environment
  vpc_id       = module.ha_vpc.vpc_id
  common_tags  = local.common_tags
  name_prefix  = local.name_prefix
}

module "ha_alb" {
  source = "./modules/ha-alb"

  project_name          = var.project_name
  stack_name            = var.stack_name
  environment           = var.environment
  vpc_id                = module.ha_vpc.vpc_id
  public_subnet_ids     = module.ha_vpc.public_subnet_ids
  alb_security_group_id = module.ha_security.alb_security_group_id
  common_tags           = local.common_tags
  name_prefix           = local.name_prefix
}

module "ha_iam" {
  source = "./modules/ha-iam"

  project_name = var.project_name
  stack_name   = var.stack_name
  environment  = var.environment
  common_tags  = local.common_tags
  name_prefix  = local.name_prefix
}

module "ha_compute" {
  source = "./modules/ha-compute"

  project_name           = var.project_name
  stack_name             = var.stack_name
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = module.ha_vpc.vpc_id
  private_subnet_ids     = module.ha_vpc.private_subnet_ids
  app_security_group_id  = module.ha_security.app_security_group_id
  instance_profile_name  = module.ha_iam.instance_profile_name
  target_group_arn       = module.ha_alb.target_group_arn
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  desired_capacity       = var.desired_capacity
  min_size               = var.min_size
  max_size               = var.max_size
  ecr_account_id         = var.ecr_account_id
  ecr_repo_name          = var.ecr_repo_name
  ecr_image_tag          = var.ecr_image_tag
  common_tags            = local.common_tags
  name_prefix            = local.name_prefix
}