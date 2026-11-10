output "database_url_secret_arn" {
  value       = aws_secretsmanager_secret.database_url.arn
  description = "ARN of the Secrets Manager secret holding DATABASE_URL."
}

output "db_instance_id" {
  value       = aws_db_instance.db.identifier
  description = "Identifier of the RDS instance, used for CloudWatch alarms."
}
