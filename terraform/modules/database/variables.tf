variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "data_subnet_ids" {
  type        = list(string)
  description = "Data subnet IDs for the DB subnet group."
}

variable "rds_sg_id" {
  type        = string
  description = "ID of the RDS security group."
}

variable "db_engine_version" {
  type        = string
  description = "PostgreSQL major version."
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB."
}

variable "db_name" {
  type        = string
  description = "Name of the database created on the instance."
}

variable "db_username" {
  type        = string
  description = "Master username for the database."
}
