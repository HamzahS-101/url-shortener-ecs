output "api_5xx_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.api_5xx.alarm_name
  description = "Name of the API 5xx alarm, used to roll back canary deployments."
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "ARN of the alerts SNS topic."
}
