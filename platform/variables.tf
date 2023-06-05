variable "ecs-cluster-name" {
  description = "ECS cluster name"
}
variable "vpc_id" {
  description = "VPC ID"
}

variable "internet_cider_blocks" {
  description = "CIDR block for SG"
}

variable "private_subnet_ids" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "ecs_domain_name" {}

variable "docker_container_port" {}
variable "task_memory" {}

variable "efs_path" {}

variable "region" {}

variable "vpc_cidr" {}

variable "tasks_count" {}

variable "account_id" {}
variable "prefix" {
}



variable "ecs_environment" {
  type = list(object({name = string, value = string}))
}

variable "ecs_container_folder_path" {
}