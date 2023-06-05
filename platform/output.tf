output "vpc_id" {
  value = var.vpc_id
}

output "ecs_elb_listener_arn" {
  value = aws_alb_listener.ecs-alb-https.arn
}

output "cluster_role_name" {
  value = aws_iam_role.ecs-cluster-role.name
}


output "cluster_role_arn" {
  value = aws_iam_role.ecs-cluster-role.arn
}

output "ecs_domain_name" {
  value = var.ecs_domain_name
}

output "public_subnets_id" {
  value = var.public_subnet_ids
}

output "task_security_groups_id" {
  value = aws_security_group.task_security_group.id
}