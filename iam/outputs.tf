output "role_name" {
  value = aws_iam_role.bc_ec2_role.name
}
output "profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "profile_arn" {
  value = aws_iam_instance_profile.ec2_profile.arn
}