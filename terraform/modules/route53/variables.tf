variable "project_name" {
  type        = string
  description = "Project name, used as a prefix for resource names."
}

variable "hosted_zone_name" {
  type        = string
  description = "Name of the existing Route53 hosted zone."
}

variable "domain_name" {
  type        = string
  description = "Domain for the ACM certificate."
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB the alias records point to."
}

variable "alb_zone_id" {
  type        = string
  description = "Hosted zone ID of the ALB."
}
