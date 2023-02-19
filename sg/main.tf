
resource "aws_security_group" "blockchain_security_group" {
  description = "Fabric Client Node Security Group"
  name = "${var.prefix}-security-groups"
  vpc_id = var.vpc_id


  ingress {
      protocol = "tcp"
      cidr_blocks = var.ssh_ingress_cidr_blocks
      from_port = 22
      to_port = 22
    }

    ingress {
      protocol = "tcp"
      cidr_blocks = var.tcp_ingress_cidr_blocks
      from_port = 0
      to_port = 65535
    }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
      Name = "Fabric Client Node SecurityGroup"
    }

}