variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = map(string)
  description = "CIDR blocks for the public subnets, keyed by availability zone."
}

variable "app_subnet_cidrs" {
  type        = map(string)
  description = "CIDR blocks for the app subnets, keyed by availability zone."
}

variable "data_subnet_cidrs" {
  type        = map(string)
  description = "CIDR blocks for the data subnets, keyed by availability zone."
}

variable "api_port" {
  type        = number
  description = "Port the API container listens on."
}

variable "dashboard_port" {
  type        = number
  description = "Port the dashboard container listens on."
}

variable "region" {
  type        = string
  description = "AWS region, used to build VPC endpoint service names."
}
