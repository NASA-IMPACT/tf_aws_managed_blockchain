variable "vpc_cidr" {
  description = "VPC CIDR"
}


variable "prefix" {

}
variable "public_subnet_1_cidr" {
  description = "Public Subnet CIDR 1"
}

variable "public_subnet_2_cidr" {
  description = "Public Subnet CIDR 2"
}

variable "public_subnet_3_cidr" {
  description = "Public Subnet CIDR 3"
}


variable "private_subnet_1_cidr" {
  description = "private Subnet CIDR 1"
}


variable "private_subnet_2_cidr" {
  description = "private Subnet CIDR 2"
}

variable "private_subnet_3_cidr" {
  description = "private Subnet CIDR 3"
}
variable "aws_region" {
 description = "Used AWS region"
}