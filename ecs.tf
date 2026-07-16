resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
      # logging    = "OVERRIDE"
      # log_configuration {
      #   cloud_watch_encryption_enabled = true
      #   cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster-logging.name
      # }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }
}













resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs-nginx.arn
  task_role_arn            = aws_iam_role.ecs-nginx.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:1.30-alpine-slim"
      essential = true
      runtimePlatform = {
        cpuArchitecture       = "X86_64",
        operatingSystemFamily = "LINUX"
      },
      portMappings = [
        {
          name          = "http"
          containerPort = 80
          protocol      = "tcp"

        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nginx.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "nginx"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private-a.id,
      aws_subnet.private-b.id,
      aws_subnet.private-c.id
    ]
    security_groups = [
      aws_security_group.internal.id
    ]
    assign_public_ip = false
  }
  enable_execute_command            = true
  force_delete                      = true
  health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
