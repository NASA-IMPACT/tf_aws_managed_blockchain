resource "aws_cloudwatch_log_group" "app-log-group" {
  name = "${var.ecs-cluster-name}-task-logGroup"
}