output "database_url_secret_arn" {
  value       = aws_secretsmanager_secret.database_url.arn
  description = "ARN of the DATABASE_URL secret."
  depends_on  = [aws_secretsmanager_secret_version.database_url]
}

output "db_instance_id" {
  value       = aws_db_instance.db.identifier
  description = "Identifier of the RDS instance."
}
