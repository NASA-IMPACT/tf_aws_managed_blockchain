terraform {
  required_providers {
    aws = {
      version = "~> 4.0"
    }
  }
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.id
  aws_region = data.aws_region.current.name
}


module "blockchain" {
  source = "./blockchain"
  prefix = "${var.prefix}a"
  blockchain_edition = var.blockchain_edition
  blockchain_protocol_framework = var.blockchain_protocol_framework
  blockchain_protocol_framework_version = var.blockchain_protocol_framework_version
  member_admin_password = "Pxyzssword!124"
  member_admin_username = var.member_admin_username
  member_description = var.member_description
  member_name = var.member_name
  network_description = var.network_description
  network_name = var.network_name
  network_proposal_duration_in_hours = var.network_proposal_duration_in_hours
  network_threshold_comparator = var.network_threshold_comparator
  network_threshold_percentage = var.network_threshold_percentage
  peernode_availabilityzone = "${local.aws_region}a"
  peernode_instance_type = var.peernode_instance_type
}

module "security_groups" {
  source = "./sg"
  vpc_id = var.vpc_id
  prefix = var.prefix
}
module "ec2_iam_role" {
  source = "./iam"
  prefix = var.prefix
}
#
#module "ec2_node" {
#  source = "./ec2"
##  ami_id = "ami-0434d5878c6ad6d4c"
#  ami_id = var.ami_id
#  key_name = "amarouane"
#  prefix = var.prefix
#  security_groups_list = [module.security_groups.sg_id]
#  subnet_id = var.subnet_id
#  with_userdata = var.with_userdata
#  ec2_profile_name = module.ec2_iam_role.profile_name
#  description = var.description
#  tag_name = var.tag_name
#  user_data_path = "${path.module}/ec2/ec2_user_data.tpl"
#  adminpwd = ""
#  adminuser = ""
#  memberid = ""
#  membername = ""
#  networkid = ""
#  networkname = ""
#  networkversion = ""
#}




module "ec2_node2" {
  source = "./ec2"
  ami_id = "ami-0434d5878c6ad6d4c"
  key_name = "amarouane"
  prefix = var.prefix
  security_groups_list = [module.security_groups.sg_id]
  subnet_id = var.subnet_id
  tag_name = "BC with automated setup 2"
  with_userdata = true
  ec2_profile_name = module.ec2_iam_role.profile_name
  description = "With automated userdata and endpoint"
  user_data_path = "${path.module}/ec2/bc_user_data.tpl"
  adminpwd = module.blockchain.managed_blockchain_MemberAdminPassword
  adminuser = module.blockchain.managed_blockchain_MemberAdminUsername
  memberid = module.blockchain.managed_blockchain_MemberId
  membername = module.blockchain.managed_blockchain_MemberName
  networkid = module.blockchain.managed_blockchain_NetworkId
  networkname = module.blockchain.managed_blockchain_NetworkName
  networkversion = module.blockchain.managed_blockchain_FrameworkVersion
  service_name = module.blockchain.managed_blockchain_service_endpoint
  vpc_id = var.vpc_id
  instance_type = var.instance_type
  channel_id     = "channelb"
  channel_codename = "mychb"
}

#
#module "elb" {
#  source = "./elb"
#  blockchain_ec2_cli_id = module.ec2_node2.ec2_instance_id
#  prefix = var.prefix
#  pub_sub = var.subnet_id
#  security_groups = module.security_groups.sg_id
#}
