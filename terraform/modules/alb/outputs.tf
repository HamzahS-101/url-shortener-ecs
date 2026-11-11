output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the ALB."
}

output "alb_zone_id" {
  value       = aws_lb.alb.zone_id
  description = "Hosted zone ID of the ALB."
}

output "alb_arn" {
  value       = aws_lb.alb.arn
  description = "ARN of the ALB."
}

output "target_group_arns" {
  value       = { for name, tg in aws_lb_target_group.target_group : name => tg.arn }
  description = "Target group ARNs keyed by service name."
  depends_on  = [aws_lb_listener_rule.host_rule]
}

output "https_listener_arn" {
  value       = aws_lb_listener.https_listener.arn
  description = "ARN of the HTTPS listener."
}
