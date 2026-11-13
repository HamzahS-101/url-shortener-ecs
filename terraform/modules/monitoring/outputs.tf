output "api_5xx_alarm_names" {
  value       = [aws_cloudwatch_metric_alarm.api_5xx.alarm_name, aws_cloudwatch_metric_alarm.api_5xx_alternate.alarm_name]
  description = "Names of the API 5xx alarms for both target groups, used to roll back canary deployments."
}

output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "ARN of the alerts SNS topic."
}
