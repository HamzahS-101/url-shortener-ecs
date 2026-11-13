locals {
  services = {
    api = {
      port         = var.api_port
      task_role    = var.task_role_arns["api"]
      health_check = null
      environment = [
        { name = "SQS_QUEUE_URL", value = var.queue_url },
        { name = "BASE_URL", value = "https://${var.domain_name}" },
        { name = "REDIS_URL", value = var.redis_url },
        { name = "FORWARDED_ALLOW_IPS", value = join(",", var.trusted_proxy_cidrs) },
      ]
    }
    worker = {
      port         = null
      task_role    = var.task_role_arns["worker"]
      health_check = ["CMD", "wget", "-qO-", "http://localhost:8090/healthz"]
      environment = [
        { name = "SQS_QUEUE_URL", value = var.queue_url },
      ]
    }
    dashboard = {
      port         = var.dashboard_port
      task_role    = null
      health_check = null
      environment  = []
    }
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  for_each          = local.services
  name              = "/ecs/${var.project_name}-${each.key}"
  retention_in_days = 7
}

data "aws_ssm_parameter" "image_tag" {
  for_each = local.services
  name     = "/${var.project_name}/${each.key}/image-tag"
}

resource "aws_ecs_task_definition" "task_definition" {
  for_each                 = local.services
  family                   = "${var.project_name}-${each.key}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_sizes[each.key].cpu
  memory                   = var.task_sizes[each.key].memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = each.value.task_role

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name         = each.key
      image        = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}-${each.key}:${data.aws_ssm_parameter.image_tag[each.key].insecure_value}"
      essential    = true
      portMappings = each.value.port == null ? [] : [{ containerPort = each.value.port, protocol = "tcp" }]
      environment  = each.value.environment

      secrets = [
        { name = "DATABASE_URL", valueFrom = var.database_url_secret_arn }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log_group[each.key].name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = each.value.health_check == null ? null : {
        command     = each.value.health_check
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
    }
  ])
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_service" "api" {
  name                              = "${var.project_name}-api"
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.task_definition["api"].arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60
  propagate_tags                    = "SERVICE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_ids["api"]]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arns["api"]
    container_name   = "api"
    container_port   = var.api_port

    advanced_configuration {
      alternate_target_group_arn = var.api_alternate_target_group_arn
      production_listener_rule   = var.api_listener_rule_arn
      role_arn                   = var.ecs_infrastructure_role_arn
    }
  }

  deployment_configuration {
    strategy             = "CANARY"
    bake_time_in_minutes = var.canary_final_bake_minutes

    canary_configuration {
      canary_percent              = var.canary_percent
      canary_bake_time_in_minutes = var.canary_bake_minutes
    }
  }

  alarms {
    enable      = true
    rollback    = true
    alarm_names = var.api_5xx_alarm_names
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}

resource "aws_ecs_service" "service" {
  for_each                           = { for name, service in local.services : name => service if name != "api" }
  name                               = "${var.project_name}-${each.key}"
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.task_definition[each.key].arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = each.value.port == null ? null : 60
  propagate_tags                     = "SERVICE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_ids[each.key]]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = each.value.port == null ? [] : [each.value.port]
    content {
      target_group_arn = var.target_group_arns[each.key]
      container_name   = each.key
      container_port   = load_balancer.value
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}
