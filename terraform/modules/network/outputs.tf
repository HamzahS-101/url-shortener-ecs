output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID of the VPC."
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
  description = "IDs of the public subnets."
}

output "app_subnet_ids" {
  value       = [for subnet in aws_subnet.app_subnet : subnet.id]
  description = "IDs of the app subnets."
}

output "data_subnet_ids" {
  value       = [for subnet in aws_subnet.data_subnet : subnet.id]
  description = "IDs of the data subnets."
}

output "private_route_table_id" {
  value       = aws_route_table.private_route_table.id
  description = "ID of the private route table."
}

output "security_group_ids" {
  value       = { for name, sg in aws_security_group.sg : name => sg.id }
  description = "Security group IDs keyed by name."
}
