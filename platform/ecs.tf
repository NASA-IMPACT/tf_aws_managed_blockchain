resource "aws_ecs_cluster" "production-fargate-cluster" {
  name = var.ecs-cluster-name
}

#####
# EFS
#####
resource "aws_efs_file_system" "efs" {
  creation_token = "${var.prefix}-efs"

  tags = {
    Name = "${var.prefix}-efs"
  }
}

resource "aws_efs_access_point" "access" {
  file_system_id = aws_efs_file_system.efs.id
}
resource "aws_security_group" "efs" {
  name   = "${var.prefix}-efs-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 2999
    to_port         = 2999
    security_groups = [aws_security_group.task_security_group.id]
    cidr_blocks     = ["10.0.0.0/16"]
  }
  ingress {
    description = "NFS traffic from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
resource "aws_efs_mount_target" "mount" {
  count = 3
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}


resource "aws_ecs_service" "ecs-service" {
  name             = var.ecs-cluster-name
  task_definition  = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count    = var.tasks_count
  cluster          = aws_ecs_cluster.production-fargate-cluster.name
  launch_type      = "FARGATE"
  platform_version = "1.4.0"


  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.task_security_group.id]
    assign_public_ip = true
  }
  load_balancer {
    container_name   = "${var.ecs-cluster-name}-task"
    container_port   = var.docker_container_port
    target_group_arn = aws_alb_target_group.ecs-app-target-group.arn
  }
  depends_on = [null_resource.ecr-image-build-push]
}