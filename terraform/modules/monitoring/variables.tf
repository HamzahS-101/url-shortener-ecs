variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "alert_email" {
  type        = string
  description = "Email address that receives alarm notifications."
  sensitive   = true
}

variable "alb_arn_suffix" {
  type        = string
  description = "ARN suffix of the ALB."
}

variable "target_group_arn_suffixes" {
  type        = map(string)
  description = "Target group ARN suffixes keyed by service name."
}

variable "dlq_name" {
  type        = string
  description = "Name of the click events dead-letter queue."
}

variable "db_instance_id" {
  type        = string
  description = "Identifier of the RDS instance."
}

variable "api_5xx_threshold" {
  type        = number
  description = "API 5xx responses per minute above which the alarm fires."
}

variable "rds_free_storage_threshold_gb" {
  type        = number
  description = "RDS free storage in GB below which the alarm fires."
}

variable "api_alternate_target_group_arn_suffix" {
  type        = string
  description = "ARN suffix of the API's alternate target group."
}
