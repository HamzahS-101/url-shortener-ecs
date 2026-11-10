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
}
