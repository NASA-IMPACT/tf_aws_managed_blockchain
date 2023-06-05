data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# MWAA Role
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }


  }
}
#tfsec:ignore:AWS099
data "aws_iam_policy_document" "ec2_policies" {
  statement {
    effect  = "Allow"
    actions = [
      "ecr:*",
      "s3:*",
      "secretsmanager:*",
      "managedblockchain:*"
    ]
    resources = [
      "*"
    ]
  }
}
