resource "aws_iam_role" "ecs-cluster-role" {
  name               = "${var.ecs-cluster-name}-role"
  assume_role_policy = file("${path.module}/templates/ecs_role.json")
}

resource "aws_iam_role_policy" "ecs-cluster-policy" {
  name   = "${var.ecs-cluster-name}-iam-policy"
  role   = aws_iam_role.ecs-cluster-role.id
  policy = file("${path.module}/templates/ecs_role_policy.json")

}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.ecs-cluster-name}-ecs-role"
  assume_role_policy = file("${path.module}/templates/ecs_task_role.json")
}


resource "aws_iam_role_policy" "ecs-task-policy" {
  name   = "${var.ecs-cluster-name}-iam-task-policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = file("${path.module}/templates/ecs_task_role_policy.json")

}