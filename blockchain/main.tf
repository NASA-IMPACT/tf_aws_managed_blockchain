data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


resource "aws_cloudformation_stack" "aws_blockchain" {
  name = "${var.prefix}-blockchain-stack"
  parameters = {
    NetworkName = var.network_name
    NetworkDescription = var.network_description
    Framework = var.blockchain_protocol_framework
    FrameworkVersion = var.blockchain_protocol_framework_version
    Edition = var.blockchain_edition
    ThresholdPercentage = var.network_threshold_percentage
    ThresholdComparator = var.network_threshold_comparator
    ProposalDurationInHours = var.network_proposal_duration_in_hours
    MemberName = var.member_name
    MemberDescription = var.member_description
    MemberAdminUsername = var.member_admin_username
    MemberAdminPassword = var.member_admin_password
    PeerNodeAvailabilityZone = var.peernode_availabilityzone
    PeerNodeInstanceType = var.peernode_instance_type

  }

  template_body = file("${path.module}/managed_blockchain_template.yml")
  timeout_in_minutes = 120
  timeouts {
    create = "120m"
  }
  capabilities = ["CAPABILITY_NAMED_IAM"]
}


resource "aws_cloudformation_stack" "aws_peer_node" {
  count = var.bc_peer_node_count > 1 ? var.bc_peer_node_count : 1
  depends_on = [aws_cloudformation_stack.aws_blockchain]
  name = "${var.prefix}-peer-node-stack"
    parameters = {
    NetworkId = aws_cloudformation_stack.aws_blockchain.outputs.NetworkId
    MemberId = aws_cloudformation_stack.aws_blockchain.outputs.MemberId
    PeerNodeAvailabilityZone = var.peernode_availabilityzone
    PeerNodeInstanceType = var.peernode_instance_type

  }

  template_body = file("${path.module}/peer_nodes_cloudformation.yml")
  timeout_in_minutes = 120
  timeouts {
    create = "120m"
  }
  capabilities = ["CAPABILITY_NAMED_IAM"]

}
