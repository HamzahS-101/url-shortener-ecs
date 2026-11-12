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

output "alb_arn_suffix" {
  value       = aws_lb.alb.arn_suffix
  description = "ARN suffix of the ALB, used as a CloudWatch metric dimension."
}

output "target_group_arn_suffixes" {
  value       = { for name, tg in aws_lb_target_group.target_group : name => tg.arn_suffix }
  description = "Target group ARN suffixes keyed by service name, used as CloudWatch metric dimensions."
}

output "api_alternate_target_group_arn" {
  value       = aws_lb_target_group.api_alternate.arn
  description = "ARN of the API's alternate target group, used by canary deployments."
}

output "api_listener_rule_arn" {
  value       = aws_lb_listener_rule.host_rule["api"].arn
  description = "ARN of the API's production listener rule, which ECS updates during canary deployments."
}
