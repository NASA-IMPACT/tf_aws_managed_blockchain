output "bs_framwork" {
  value = module.blockchain.managed_blockchain.Framework
}

output "bs_framwork_version" {
  value = module.blockchain.managed_blockchain.FrameworkVersion
}

output "bs_member_admin_username" {
  value = module.blockchain.managed_blockchain.MemberAdminUsername
}

#output "bc_ec2_ip" {
#  value = module.ec2_node.ec2_ip
#}

output "bc_ec2_ip_2" {
  value = module.ec2_node2.ec2_ip
}
output "ec2_profile_arn" {
  value = module.ec2_iam_role.profile_arn
}

output "bc_sevice_endpoint" {
  value = module.blockchain.managed_blockchain_service_endpoint
}

