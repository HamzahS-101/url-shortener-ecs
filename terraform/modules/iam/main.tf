locals {
  services = ["api", "worker", "dashboard"]

  # SQS actions each task role is allowed on the click events queue
  task_role_sqs_actions = {
    api    = ["sqs:SendMessage"]
    worker = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:ChangeMessageVisibility", "sqs:GetQueueAttributes"]
  }

  ecs_tasks_trust_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = { "aws:SourceAccount" = var.account_id }
          ArnLike      = { "aws:SourceArn" = "arn:aws:ecs:${var.region}:${var.account_id}:*" }
        }
      }
    ]
  })
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.project_name}-execution-role"
  assume_role_policy = local.ecs_tasks_trust_policy
}

resource "aws_iam_role_policy" "execution_policy" {
  name = "${var.project_name}-execution-policy"
  role = aws_iam_role.execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "EcrPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [for service in local.services : "arn:aws:ecr:${var.region}:${var.account_id}:repository/${var.project_name}-${service}"]
      },
      {
        Sid      = "Logs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [for service in local.services : "arn:aws:logs:${var.region}:${var.account_id}:log-group:/ecs/${var.project_name}-${service}:*"]
      },
      {
        Sid      = "DatabaseSecret"
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = var.database_url_secret_arn
      }
    ]
  })
}

resource "aws_iam_role" "task_role" {
  for_each           = local.task_role_sqs_actions
  name               = "${var.project_name}-${each.key}-task-role"
  assume_role_policy = local.ecs_tasks_trust_policy
}

resource "aws_iam_role_policy" "task_policy" {
  for_each = local.task_role_sqs_actions
  name     = "${var.project_name}-${each.key}-task-policy"
  role     = aws_iam_role.task_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ClickEventsQueue"
        Effect   = "Allow"
        Action   = each.value
        Resource = var.queue_arn
      }
    ]
  })
}
