variable "prefix" {
  default = "bcamarouane"
}
variable "network_name" {
  type = string
  default = "blockchain1234"
}
variable "network_description" {
  default = "Network for tracking files and sharing them between organisations"
}
variable "blockchain_edition" {
  default = "STARTER"
}
variable "network_threshold_percentage" {
  default = 50

}
variable "network_threshold_comparator" {
  default = "GREATER_THAN"

}
variable "network_proposal_duration_in_hours" {
  type = number
  default = 24
}


variable "member_name" {
  type = string
  default = "mamarouane"
}
variable "member_description" {
  type = string
  default = "This is the first member"
}
variable "member_admin_username" {
  description = "The user name of your member's admin user."
  default = "amarouane"
}
variable "member_admin_password" {
  description = "The password of your member's admin user."
  default = "Amarouanedminpwd1!"
}

variable "peernode_instance_type" {
  description = "The type of compute instance to use for your peer nodes."
  default = "bc.t3.small"
}

variable "blockchain_protocol_framework" {
  description = "The blockchain protocol to use, such as Hyperledger Fabric"
  default = "HYPERLEDGER_FABRIC"
}
variable "blockchain_protocol_framework_version" {
  description = "The version of the blockchain protocol to use"
  default = "2.2"
}

variable "vpc_id" {
  default = "vpc-068cae278b205376f"
}
variable "ami_id" {
  default = "ami-0dfcb1ef8550277af"
}
variable "subnet_id" {
  default = "subnet-00806dd9f5ff7fb34"
}

variable "with_userdata" {
 default = true
}

variable "description" {
default = "Blockchain instance"
}

variable "tag_name" {
  default = "BC cli EC2"
}

variable "instance_type" {
 default = "t2.medium"
}