variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC the target groups belong to."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs to place the ALB in."
}

variable "alb_sg_id" {
  type        = string
  description = "ID of the ALB security group."
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the validated ACM certificate for the HTTPS listener."
}

variable "domain_name" {
  type        = string
  description = "Domain the API is served on."
}

variable "api_port" {
  type        = number
  description = "Port the API container listens on."
}

variable "dashboard_port" {
  type        = number
  description = "Port the dashboard container listens on."
}

variable "waf_rate_limit" {
  type        = number
  description = "Maximum requests per IP in a 5-minute window before WAF blocks it."
}
