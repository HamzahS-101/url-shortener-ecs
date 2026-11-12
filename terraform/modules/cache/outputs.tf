output "redis_url" {
  value       = "rediss://${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
  description = "TLS connection URL for the Redis primary endpoint."
}
