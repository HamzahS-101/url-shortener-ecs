variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "database_url_secret_arn" {
  type        = string
  description = "ARN of the DATABASE_URL secret."
}

variable "queue_arn" {
  type        = string
  description = "ARN of the click events queue."
}

variable "account_id" {
  type        = string
  description = "AWS account ID, used to build resource ARNs and URLs."
}

variable "region" {
  type        = string
  description = "AWS region."
}
