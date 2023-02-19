
resource "aws_vpc" "blockchain_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy = var.instance_tenancy
  tags = var.tags
}



resource "aws_subnet" "blockchain_public_subnet" {
  vpc_id = aws_vpc.blockchain_vpc.arn
  map_public_ip_on_launch = var.map_public_ip_on_launch
  cidr_block = var.pub_subnet_cidr_block
  tags = [
    {
      Key = "Name"
      Value = "PublicSubnet"
    }
  ]
}