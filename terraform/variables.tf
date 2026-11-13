# General

variable "region" {
  type        = string
  description = "AWS region to deploy resources in."
  default     = "eu-west-2"
}

variable "account_id" {
  type        = string
  description = "AWS account ID, used to build resource ARNs and URLs."
  default     = "188735374190"
}

variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names and in tags."
  default     = "url-shortener"
}

variable "environment" {
  type        = string
  description = "Environment name used in tags (e.g., prod)."
  default     = "prod"
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

variable "desired_count" {
  type        = number
  description = "Number of tasks to run per service."
  default     = 2
}

variable "task_sizes" {
  type        = map(object({ cpu = number, memory = number }))
  description = "Fargate CPU and memory per service."
  default = {
    api       = { cpu = 256, memory = 512 }
    worker    = { cpu = 256, memory = 512 }
    dashboard = { cpu = 256, memory = 512 }
  }
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
  description = "PostgreSQL major version"
  default     = "16"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t4g.micro"
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version"
  default     = "7.1"
}

variable "redis_node_type" {
  type        = string
  description = "ElastiCache node type"
  default     = "cache.t4g.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
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

variable "alert_email" {
  type        = string
  description = "Email address for alarm notifications. Set with TF_VAR_alert_email, not committed."
  sensitive   = true
}

variable "api_5xx_threshold" {
  type        = number
  description = "API 5xx responses per minute above which the alarm fires"
  default     = 5
}

variable "rds_free_storage_threshold_gb" {
  type        = number
  description = "RDS free storage in GB below which the alarm fires"
  default     = 2
}

variable "canary_percent" {
  type        = number
  description = "Percentage of API traffic sent to the new version during the canary phase"
  default     = 10
}

variable "canary_bake_minutes" {
  type        = number
  description = "Minutes the canary runs before the rest of the traffic moves over"
  default     = 5
}

variable "canary_final_bake_minutes" {
  type        = number
  description = "Minutes the old API version is kept after all traffic has moved"
  default     = 5
}
