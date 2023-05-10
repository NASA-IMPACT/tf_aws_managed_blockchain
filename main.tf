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
  ec2_cli_count = flatten([
    for indx, bc_channel in var.ec2_cli_configuration : {
      indx             = indx
      channel_id       = bc_channel.channel_id
      channel_codename = bc_channel.channel_codename
      key_pair_name    = bc_channel.key_pair_name
      instance_type    = bc_channel.instance_type
    }
  ])


  channel_map = {
    for ch in local.ec2_cli_count : ch.channel_id => ch
  }
}


module "blockchain" {
  source                                = "./blockchain"
  prefix                                = "${var.prefix}a"
  blockchain_edition                    = var.blockchain_edition
  blockchain_protocol_framework         = var.blockchain_protocol_framework
  blockchain_protocol_framework_version = var.blockchain_protocol_framework_version
  member_admin_password                 = var.member_admin_password
  member_admin_username                 = var.member_admin_username
  member_description                    = var.member_description
  member_name                           = var.member_name
  network_description                   = var.network_description
  network_name                          = var.network_name
  network_proposal_duration_in_hours    = var.network_proposal_duration_in_hours
  network_threshold_comparator          = var.network_threshold_comparator
  network_threshold_percentage          = var.network_threshold_percentage
  peernode_availabilityzone             = "${local.aws_region}a"
  peernode_instance_type                = var.peernode_instance_type
  bc_peer_node_count                    = var.bc_peer_node_count
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


module "bc_ecr" {
  source = "./ecr"
  account_id = data.aws_caller_identity.current.id
  aws_region = data.aws_region.current.name
  docker_file_path = var.docker_file_path
  ecs_container_folder_path = var.ecs_container_folder_path
  prefix = var.prefix
}

module "ec2_client" {
  for_each             = local.channel_map
  source               = "./ec2"
  ami_id               = var.ami_id
  prefix               = var.prefix
  security_groups_list = [module.security_groups.sg_id]
  subnet_id            = var.subnet_id
  tag_name             = "${var.prefix} EC2 client"
  with_userdata        = true
  ec2_profile_name     = module.ec2_iam_role.profile_name
  description          = "With automated userdata and endpoint"
  user_data_path       = "${path.module}/ec2/bc_user_data.tpl"
  adminpwd             = module.blockchain.managed_blockchain_MemberAdminPassword
  adminuser            = module.blockchain.managed_blockchain_MemberAdminUsername
  memberid             = module.blockchain.managed_blockchain_MemberId
  membername           = module.blockchain.managed_blockchain_MemberName
  networkid            = module.blockchain.managed_blockchain_NetworkId
  networkname          = module.blockchain.managed_blockchain_NetworkName
  networkversion       = module.blockchain.managed_blockchain_FrameworkVersion
  vpc_id               = var.vpc_id
  instance_type        = local.channel_map[each.key].instance_type
  key_name             = local.channel_map[each.key].key_pair_name
  channel_id           = local.channel_map[each.key].channel_id
  channel_codename     = local.channel_map[each.key].channel_codename
  member_node_id       = module.blockchain.managed_blockchain_MemberPeerNodeId[local.channel_map[each.key].indx]
  s3_uri_bc_code       = var.s3_uri_bc_code
  rest_api_docker_image_url = module.bc_ecr.rest_api_ecr_repo_url
  storage_bucket = var.storage_bucket
}
module "vpc_endpoint" {
  source = "./vpc"

  prefix               = var.prefix
  security_groups_list = [module.security_groups.sg_id]
  service_name         = module.blockchain.managed_blockchain_service_endpoint
  subnet_id            = var.subnet_id
  vpc_id               = var.vpc_id
}

