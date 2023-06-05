resource "aws_security_group" "ecs-alb-sg" {
  name        = "${var.ecs-cluster-name}=alb-sg"
  description = "Security group for ALB to traffic for ECS cluster"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = [var.internet_cider_blocks]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.internet_cider_blocks]
  }
}


#====== Security Group for ECS Fargate task Begin =====

resource "aws_security_group" "task_security_group" {
  name        = "${var.ecs-cluster-name}-task-sg"
  description = "SG for the app to allow inbounds and outbounds"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = var.docker_container_port
    protocol    = "TCP"
    to_port     = var.docker_container_port
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.internet_cider_blocks]
  }
  tags = {
    Name = "${var.ecs-cluster-name}-task-sg"
  }
}