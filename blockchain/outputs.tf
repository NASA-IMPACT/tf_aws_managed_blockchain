output "managed_blockchain" {
  value = aws_cloudformation_stack.aws_blockchain.outputs
}

output "managed_blockchain_MemberId" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.MemberId
}

output "managed_blockchain_MemberName" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.MemberName
}
output "managed_blockchain_NetworkId" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.NetworkId
}
output "managed_blockchain_NetworkName" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.NetworkName
}
output "managed_blockchain_Framework" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.Framework
}
output "managed_blockchain_FrameworkVersion" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.FrameworkVersion
}
output "managed_blockchain_MemberPeerNodeId" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.MemberPeerNodeId
}

output "managed_blockchain_MemberAdminUsername" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.MemberAdminUsername
}

output "managed_blockchain_MemberAdminPassword" {
  value = aws_cloudformation_stack.aws_blockchain.outputs.MemberAdminPassword
}

output "managed_blockchain_service_endpoint" {
  value = "com.amazonaws.${data.aws_region.current.name}.managedblockchain.${lower(aws_cloudformation_stack.aws_blockchain.outputs.NetworkId)}"
}