locals {
  # Security groups to create: name => description
  security_groups = {
    alb       = "Public HTTP and HTTPS to the ALB"
    api       = "API tasks"
    dashboard = "Dashboard tasks"
    worker    = "Worker tasks"
    rds       = "PostgreSQL from the app tasks only"
    endpoints = "HTTPS to VPC interface endpoints from the app tasks"
  }

  # Inbound rules: sg allows port from a cidr or a source security group
  ingress_rules = {
    alb_http                 = { sg = "alb", port = 80, cidr = "0.0.0.0/0" }
    alb_https                = { sg = "alb", port = 443, cidr = "0.0.0.0/0" }
    api_from_alb             = { sg = "api", port = var.api_port, source = "alb" }
    dashboard_from_alb       = { sg = "dashboard", port = var.dashboard_port, source = "alb" }
    rds_from_api             = { sg = "rds", port = 5432, source = "api" }
    rds_from_dashboard       = { sg = "rds", port = 5432, source = "dashboard" }
    rds_from_worker          = { sg = "rds", port = 5432, source = "worker" }
    endpoints_from_api       = { sg = "endpoints", port = 443, source = "api" }
    endpoints_from_dashboard = { sg = "endpoints", port = 443, source = "dashboard" }
    endpoints_from_worker    = { sg = "endpoints", port = 443, source = "worker" }
  }

  # Outbound rules: sg allows port to a cidr, a destination security group or a prefix list
  egress_rules = {
    alb_to_api             = { sg = "alb", port = var.api_port, destination = "api" }
    alb_to_dashboard       = { sg = "alb", port = var.dashboard_port, destination = "dashboard" }
    api_to_endpoints       = { sg = "api", port = 443, destination = "endpoints" }
    dashboard_to_endpoints = { sg = "dashboard", port = 443, destination = "endpoints" }
    worker_to_endpoints    = { sg = "worker", port = 443, destination = "endpoints" }
    api_to_s3              = { sg = "api", port = 443, prefix_list = aws_vpc_endpoint.s3.prefix_list_id }
    dashboard_to_s3        = { sg = "dashboard", port = 443, prefix_list = aws_vpc_endpoint.s3.prefix_list_id }
    worker_to_s3           = { sg = "worker", port = 443, prefix_list = aws_vpc_endpoint.s3.prefix_list_id }
    api_to_rds             = { sg = "api", port = 5432, destination = "rds" }
    dashboard_to_rds       = { sg = "dashboard", port = 5432, destination = "rds" }
    worker_to_rds          = { sg = "worker", port = 5432, destination = "rds" }
  }
}

resource "aws_security_group" "sg" {
  for_each    = local.security_groups
  name        = "${var.project_name}-${each.key}-sg"
  description = each.value
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${each.key}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each                     = local.ingress_rules
  security_group_id            = aws_security_group.sg[each.value.sg].id
  description                  = replace(each.key, "_", " ")
  cidr_ipv4                    = try(each.value.cidr, null)
  referenced_security_group_id = try(aws_security_group.sg[each.value.source].id, null)
  ip_protocol                  = "tcp"
  from_port                    = each.value.port
  to_port                      = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each                     = local.egress_rules
  security_group_id            = aws_security_group.sg[each.value.sg].id
  description                  = replace(each.key, "_", " ")
  cidr_ipv4                    = try(each.value.cidr, null)
  referenced_security_group_id = try(aws_security_group.sg[each.value.destination].id, null)
  prefix_list_id               = try(each.value.prefix_list, null)
  ip_protocol                  = "tcp"
  from_port                    = each.value.port
  to_port                      = each.value.port
}
