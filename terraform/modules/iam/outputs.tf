output "execution_role_arn" {
  value       = aws_iam_role.execution_role.arn
  description = "ARN of the ECS task execution role."
}

output "task_role_arns" {
  value       = { for name, role in aws_iam_role.task_role : name => role.arn }
  description = "Task role ARNs keyed by service name."
}
