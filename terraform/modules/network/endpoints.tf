locals {
  interface_endpoints = toset(["ecr.api", "ecr.dkr", "logs", "sqs", "secretsmanager"])
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = local.interface_endpoints
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.app_subnet : subnet.id]
  security_group_ids  = [aws_security_group.sg["endpoints"].id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${replace(each.key, ".", "-")}-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}
