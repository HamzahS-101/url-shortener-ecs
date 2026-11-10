# General

variable "region" {
  type        = string
  description = "AWS region to deploy resources in."
  default     = "eu-west-2"
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
