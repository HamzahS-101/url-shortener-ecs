module "network" {
  source = "./modules/network"

  project_name        = var.project_name
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
