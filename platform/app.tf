


resource "aws_ecs_task_definition" "ecs-task-definition" {


  container_definitions = jsonencode([
    {
      name : "${var.ecs-cluster-name}-task",
      image : "${aws_ecr_repository.app-ecr.repository_url}:latest",
      essential : true,
      mountPoints : [
        {
          "containerPath" : "/app/credential-store",
          "sourceVolume" : "efs-${var.prefix}"

        }
      ],
      cpu : 0
      environment : var.ecs_environment,
      volumesFrom : []
      portMappings : [{
        "hostPort" : var.docker_container_port
        "protocol" : "tcp"
        "containerPort" : var.docker_container_port
      }],
      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${var.ecs-cluster-name}-task-logGroup",
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "${var.ecs-cluster-name}-logGroup-stream"
        }
      }
    }

  ])
  family                   = "${var.prefix}-tasks"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = 1024
  memory                   = 2048
  volume {
    name = "efs-${var.prefix}"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.efs.id
      root_directory          = "/mnt/data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.access.id
        iam             = "ENABLED"
      }
    }
  }
  tags = {
    Name = var.prefix
  }
}
