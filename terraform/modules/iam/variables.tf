variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names. ECR repos and log groups follow <project_name>-<service>."
}

variable "database_url_secret_arn" {
  type        = string
  description = "ARN of the DATABASE_URL secret the execution role can read."
}

variable "queue_arn" {
  type        = string
  description = "ARN of the click events queue the task roles can use."
}

variable "account_id" {
  type        = string
  description = "AWS account ID, used to build resource ARNs in the policies."
}

variable "region" {
  type        = string
  description = "AWS region, used to build resource ARNs in the policies."
}
