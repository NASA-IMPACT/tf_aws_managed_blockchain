data "aws_region" "current" {}
data "aws_caller_identity" "current" {}



resource "aws_instance" "ec2_instance" {
  ami                         = var.ami_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.key_name == null ? false : true


  instance_type = var.instance_type
  tags = {
    Name        = var.tag_name
    Description = var.description
  }
  key_name = var.key_name


  iam_instance_profile = var.ec2_profile_name
  user_data = templatefile(var.user_data_path, {
    docker_image    = var.docker_image
    NETWORKNAME     = var.networkname
    MEMBERNAME      = var.membername
    NETWORKVERSION  = var.networkversion
    ADMINUSER       = var.adminuser
    ADMINPWD        = var.adminpwd
    NETWORKID       = var.networkid
    MEMBERID        = var.memberid
    REGION          = data.aws_region.current.name
    CHANNELID       = var.channel_id
    CHANNELCODENAME = var.channel_codename
    MEMEBERNODEID   = var.member_node_id
    S3URIBCCODE     = var.s3_uri_bc_code
    AWS_REGION = data.aws_region.current.name
    ACCOUNT_ID = data.aws_caller_identity.current.id
    SECRET_SSM_NAME = var.secret_ssm_name
    TRIGGER_BUILD = timestamp()
  })
  vpc_security_group_ids = var.security_groups_list
}


