output "queue_url" {
  value       = aws_sqs_queue.click_events.id
  description = "URL of the click events queue, passed to the api and worker as SQS_QUEUE_URL."
}

output "queue_arn" {
  value       = aws_sqs_queue.click_events.arn
  description = "ARN of the click events queue, used in task role policies."
}

output "dlq_name" {
  value       = aws_sqs_queue.click_events_dlq.name
  description = "Name of the dead-letter queue, used for the DLQ alarm."
}
