locals {
  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "logs",
    "secretsmanager",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "ec2",
  ]
  custom-header-name = "X-CF-Secure-Header"
}
