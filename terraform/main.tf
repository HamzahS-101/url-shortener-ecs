module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  data_subnet_cidrs   = var.data_subnet_cidrs
  api_port            = var.api_port
  dashboard_port      = var.dashboard_port
}

module "route53" {
  source = "./modules/route53"

  project_name     = var.project_name
  hosted_zone_name = var.hosted_zone_name
  domain_name      = var.domain_name
  alb_dns_name     = module.alb.alb_dns_name
  alb_zone_id      = module.alb.alb_zone_id
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.network.security_group_ids["alb"]
  certificate_arn   = module.route53.certificate_arn
  domain_name       = var.domain_name
  api_port          = var.api_port
  dashboard_port    = var.dashboard_port
  waf_rate_limit    = var.waf_rate_limit
}

module "database" {
  source = "./modules/database"

  project_name         = var.project_name
  data_subnet_ids      = module.network.data_subnet_ids
  rds_sg_id            = module.network.security_group_ids["rds"]
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
}

module "cache" {
  source = "./modules/cache"

  project_name         = var.project_name
  data_subnet_ids      = module.network.data_subnet_ids
  redis_sg_id          = module.network.security_group_ids["redis"]
  redis_engine_version = var.redis_engine_version
  redis_node_type      = var.redis_node_type
}

module "sqs" {
  source = "./modules/sqs"

  project_name = var.project_name
}

module "iam" {
  source = "./modules/iam"

  project_name            = var.project_name
  account_id              = var.account_id
  region                  = var.region
  database_url_secret_arn = module.database.database_url_secret_arn
  queue_arn               = module.sqs.queue_arn
}

module "ecs" {
  source = "./modules/ecs"

  project_name            = var.project_name
  account_id              = var.account_id
  region                  = var.region
  api_port                = var.api_port
  dashboard_port          = var.dashboard_port
  domain_name             = var.domain_name
  desired_count           = var.desired_count
  task_sizes              = var.task_sizes
  subnet_ids              = module.network.app_subnet_ids
  security_group_ids      = module.network.security_group_ids
  target_group_arns       = module.alb.target_group_arns
  execution_role_arn      = module.iam.execution_role_arn
  task_role_arns          = module.iam.task_role_arns
  database_url_secret_arn = module.database.database_url_secret_arn
  queue_url               = module.sqs.queue_url
  redis_url               = module.cache.redis_url
  trusted_proxy_cidrs     = values(var.public_subnet_cidrs)
}
