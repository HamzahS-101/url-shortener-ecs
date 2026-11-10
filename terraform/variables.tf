# General

variable "region" {
  type        = string
  description = "AWS region to deploy resources in."
  default     = "eu-west-2"
}

variable "account_id" {
  type        = string
  description = "AWS account ID the resources are deployed to."
  default     = "188735374190"
}

variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names and in tags."
  default     = "url-shortener"
}

variable "environment" {
  type        = string
  description = "Environment name used in tags (e.g., dev)."
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Owner of the resources, used in tags."
  default     = "hamzah"
}

# VPC

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = map(string)
  description = "CIDR blocks for the public subnets (ALB), keyed by availability zone."
  default = {
    "eu-west-2a" = "10.0.1.0/24"
    "eu-west-2b" = "10.0.2.0/24"
  }
}

variable "app_subnet_cidrs" {
  type        = map(string)
  description = "CIDR blocks for the app subnets (ECS tasks, VPC endpoints), keyed by availability zone."
  default = {
    "eu-west-2a" = "10.0.11.0/24"
    "eu-west-2b" = "10.0.12.0/24"
  }
}

variable "data_subnet_cidrs" {
  type        = map(string)
  description = "CIDR blocks for the data subnets (RDS, Redis), keyed by availability zone."
  default = {
    "eu-west-2a" = "10.0.21.0/24"
    "eu-west-2b" = "10.0.22.0/24"
  }
}

# Services

variable "api_port" {
  type        = number
  description = "Port the API container listens on."
  default     = 8080
}

variable "dashboard_port" {
  type        = number
  description = "Port the dashboard container listens on."
  default     = 8081
}

# Route53

variable "hosted_zone_name" {
  type        = string
  description = "Name of the Route53 hosted zone, created manually."
  default     = "url.hamzahsahal.com"
}

variable "domain_name" {
  type        = string
  description = "Domain the API is served on. The dashboard uses dashboard.<domain_name>."
  default     = "url.hamzahsahal.com"
}

# WAF

variable "waf_rate_limit" {
  type        = number
  description = "Maximum requests per IP in a 5-minute window before WAF blocks it."
  default     = 100
}

# Database

variable "db_engine_version" {
  type        = string
  description = "PostgreSQL major version (matches postgres:16 in docker-compose)."
  default     = "16"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class (Graviton, smallest available)."
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB (20 is the gp3 minimum)."
  default     = 20
}

variable "db_name" {
  type        = string
  description = "Name of the database created on the instance."
  default     = "shortener"
}

variable "db_username" {
  type        = string
  description = "Master username for the database."
  default     = "app"
}
