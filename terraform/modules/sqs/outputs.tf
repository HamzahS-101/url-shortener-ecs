output "queue_url" {
  value       = aws_sqs_queue.click_events.id
  description = "URL of the click events queue."
}

output "queue_arn" {
  value       = aws_sqs_queue.click_events.arn
  description = "ARN of the click events queue."
}

output "dlq_name" {
  value       = aws_sqs_queue.click_events_dlq.name
  description = "Name of the dead-letter queue."
}
