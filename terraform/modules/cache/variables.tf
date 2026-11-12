variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "data_subnet_ids" {
  type        = list(string)
  description = "Data subnet IDs for the cache subnet group."
}

variable "redis_sg_id" {
  type        = string
  description = "ID of the Redis security group."
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version."
}

variable "redis_node_type" {
  type        = string
  description = "ElastiCache node type."
}
