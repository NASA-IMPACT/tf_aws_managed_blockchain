data "aws_region" "current" {}


resource "aws_instance" "ec2_instance" {
  ami = var.ami_id
  subnet_id = var.subnet_id
  associate_public_ip_address = true


  instance_type = var.instance_type
  tags = {
    Name = var.tag_name
    Description = var.description
  }
  key_name = var.key_name


  iam_instance_profile = var.ec2_profile_name
  user_data = var.with_userdata ?  templatefile(var.user_data_path,{
    docker_image = var.docker_image
    NETWORKNAME = var.networkname
    MEMBERNAME = var.membername
    NETWORKVERSION = var.networkversion
    ADMINUSER= var.adminuser
    ADMINPWD= var.adminpwd
    NETWORKID= var.networkid
    MEMBERID= var.memberid
    REGION = data.aws_region.current.name
    CHANNELID = var.channel_id
    CHANNELCODENAME = var.channel_codename

  } ) : null
  vpc_security_group_ids = var.security_groups_list
}


resource "aws_vpc_endpoint" "blockchain_vpc_endpoint" {
  vpc_id       = var.vpc_id
  service_name = var.service_name
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [var.subnet_id]
  security_group_ids = var.security_groups_list

  tags = {
    Environment = "${var.prefix}-vpc_endpoint"
  }
}
