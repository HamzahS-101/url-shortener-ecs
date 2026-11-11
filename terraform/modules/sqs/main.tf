resource "aws_sqs_queue" "click_events_dlq" {
  name                      = "${var.project_name}-click-events-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

  tags = {
    Name = "${var.project_name}-click-events-dlq"
  }
}

resource "aws_sqs_queue" "click_events" {
  name                       = "${var.project_name}-click-events"
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 345600
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.click_events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name = "${var.project_name}-click-events"
  }
}

resource "aws_sqs_queue_redrive_allow_policy" "click_events_dlq" {
  queue_url = aws_sqs_queue.click_events_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.click_events.arn]
  })
}
