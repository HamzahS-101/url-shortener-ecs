variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "api_port" {
  type        = number
  description = "Port the API container listens on."
}

variable "dashboard_port" {
  type        = number
  description = "Port the dashboard container listens on."
}

variable "domain_name" {
  type        = string
  description = "Domain the API is served on."
}

variable "queue_url" {
  type        = string
  description = "URL of the click events queue."
}

variable "redis_url" {
  type        = string
  description = "Redis connection URL for the API cache."
}

variable "trusted_proxy_cidrs" {
  type        = list(string)
  description = "CIDR blocks the API trusts to set X-Forwarded-For (the ALB's subnets)."
}

variable "task_role_arns" {
  type        = map(string)
  description = "Task role ARNs keyed by service name."
}

variable "account_id" {
  type        = string
  description = "AWS account ID, used to build resource ARNs and URLs."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role."
}

variable "database_url_secret_arn" {
  type        = string
  description = "ARN of the DATABASE_URL secret."
}

variable "task_sizes" {
  type        = map(object({ cpu = number, memory = number }))
  description = "Fargate CPU and memory per service."
}

variable "desired_count" {
  type        = number
  description = "Number of tasks to run per service."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to run the tasks in."
}

variable "security_group_ids" {
  type        = map(string)
  description = "Security group IDs keyed by service name."
}

variable "target_group_arns" {
  type        = map(string)
  description = "Target group ARNs keyed by service name."
}
