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
  aws_secret_manager_name = "${var.prefix}-ssm-secrets"
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
module "network" {
  source = "./network"
  prefix = var.prefix
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  private_subnet_3_cidr = var.private_subnet_3_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  public_subnet_3_cidr = var.public_subnet_3_cidr
  vpc_cidr = var.vpc_cidr
  aws_region = local.aws_region
}
module "security_groups" {
  source = "./sg"
  vpc_id = module.network.vpv_id
  prefix = var.prefix
}
module "ec2_iam_role" {
  source = "./iam"
  prefix = var.prefix
}


module "ec2_client" {
  for_each             = local.channel_map
  source               = "./ec2"
  ami_id               = var.ami_id
  prefix               = var.prefix
  security_groups_list = [module.security_groups.sg_id]
  subnet_id            = module.network.public_subnet_1_id
  tag_name             = "${var.prefix} EC2 client"
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
  vpc_id               = module.network.vpv_id
  instance_type        = local.channel_map[each.key].instance_type
  key_name             = local.channel_map[each.key].key_pair_name
  channel_id           = local.channel_map[each.key].channel_id
  channel_codename     = local.channel_map[each.key].channel_codename
  member_node_id       = module.blockchain.managed_blockchain_MemberPeerNodeId[0]
  s3_uri_bc_code       = var.s3_uri_bc_code
  secret_ssm_name = local.aws_secret_manager_name
}



module "platform" {
  source                = "./platform"
  depends_on = [module.ec2_client]
  ecs-cluster-name      = var.ecs-cluster-name
  ecs_domain_name       = var.ecs_domain_name
  internet_cider_blocks = var.internet_cider_blocks
  public_subnet_ids     = split(",", "${module.network.public_subnet_1_id},${module.network.public_subnet_2_id},${module.network.public_subnet_3_id}")
  vpc_id                = module.network.vpv_id
  docker_container_port = var.docker_container_port
  efs_path              = var.efs_path
  region                = local.aws_region
  task_memory           = var.task_memory
  tasks_count           = var.tasks_count
  vpc_cidr              = var.vpc_cidr
  account_id = data.aws_caller_identity.current.account_id
  private_subnet_ids    = split(",", "${module.network.private_subnet_1_id},${module.network.private_subnet_2_id},${module.network.private_subnet_3_id}")
  ecs_environment       = concat([
    { name = "SECRET_SSM_NAME", value = local.aws_secret_manager_name },
    { name = "AWS_DEFAULT_REGION", value = local.aws_region},
    ], var.ecs_environment)
  prefix = var.prefix
  ecs_container_folder_path = var.ecs_container_folder_path
}


resource "aws_vpc_endpoint" "blockchain_vpc_endpoint" {
  vpc_id       = module.network.vpv_id
  service_name = module.blockchain.managed_blockchain_service_endpoint
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [module.network.private_subnet_1_id, module.network.private_subnet_2_id]
  security_group_ids = [module.security_groups.sg_id, module.platform.task_security_groups_id]

  tags = {
    Environment = "${var.prefix}-vpc_endpoint"
  }
}


