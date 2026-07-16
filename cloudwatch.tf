resource "aws_cloudwatch_log_group" "cluster-logging" {
  name              = "/ecs/cluster/logging"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.project_name}-nginx"
  retention_in_days = 14
}
