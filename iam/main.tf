
resource "aws_iam_role" "bc_ec2_role" {
  name                  = "${var.prefix}-bc_ec2_cli_g_role"
  description           = "bc role"
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  path                  = "/"
  permissions_boundary = var.permissions_boundary


  tags = {
    Name = "IAM role for BC EC2"
  }
}

resource "aws_iam_role_policy" "ecs-task-policy" {
  name   = "${var.prefix}-iam-task-g-policy"
  role   = aws_iam_role.bc_ec2_role.id
  policy = data.aws_iam_policy_document.ec2_policies.json

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-ec2_profile"
  role = aws_iam_role.bc_ec2_role.name
}