
variable "tag_name" {

}

variable "instance_type" {

}
variable "channel_id" {
}

variable "channel_codename" {
}

variable "docker_image" {
  default = "blockchain"
}
variable "description" {

}
variable "ec2_profile_name" {
}
variable "with_userdata" {
  type = bool
}

variable "ami_id" {

}
variable "key_name" {

}
variable "prefix" {
  type        = string
  description = "Stack prefix"
}
variable "security_groups_list" {
  type = list(string)
}

variable "subnet_id" {
}

variable "user_data_path" {
}

variable "networkname" {
}
variable "membername" {
}
variable "networkversion" {
}
variable "adminuser" {
}
variable "adminpwd" {
}
variable "networkid" {
}
variable "memberid" {
}

variable "vpc_id" {

}
variable "member_node_id" {
}

variable "s3_uri_bc_code" {
  description = "S# URI to blockchain code (compressed gz)"
}