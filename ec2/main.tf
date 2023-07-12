data "aws_region" "current" {}
data "aws_caller_identity" "current" {}



resource "aws_instance" "ec2_instance" {
  ami                         = var.ami_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true


  instance_type = var.instance_type
  tags = {
    Name        = var.tag_name
    Description = var.description
  }
  key_name = var.key_name


  iam_instance_profile = var.ec2_profile_name
  user_data = var.with_userdata ? templatefile(var.user_data_path, {
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
    REST_API_DOCKER_IMAGE_URL = var.rest_api_docker_image_url
    STORAGE_BUCKET = var.storage_bucket

  }) : null
  vpc_security_group_ids = var.security_groups_list
}


resource "aws_eip" "lb" {
  instance = aws_instance.ec2_instance.id
  tags = {
    Name        = "BC EIP ${var.tag_name}"
  }
  vpc      = true
}
