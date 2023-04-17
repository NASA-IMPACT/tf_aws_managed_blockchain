output "bc_framework" {
  value = module.blockchain.managed_blockchain.Framework
}

output "bc_framework_version" {
  value = module.blockchain.managed_blockchain.FrameworkVersion
}

output "bc_member_admin_username" {
  value = module.blockchain.managed_blockchain.MemberAdminUsername
}

#output "bc_ec2_ip" {
#  value = module.ec2_node.ec2_ip
#}

output "bc_ec2_ip" {

  value = [
    for ec2 in module.ec2_client : "IP:${ec2.ec2_ip} Key_Name: ${ec2.ec2_instance_key_name} Channel: ${ec2.channel_id}"
  ]

}
output "ec2_profile_arn" {
  value = module.ec2_iam_role.profile_arn
}

output "bc_sevice_endpoint" {
  value = module.blockchain.managed_blockchain_service_endpoint
}

output "node_ids" {
  value = module.blockchain.managed_blockchain_MemberPeerNodeId
}

