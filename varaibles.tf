variable "prefix" {
  type = string
}
variable "network_name" {
  type = string

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
  type    = number
  default = 24
}


variable "member_name" {
  type = string
}
variable "member_description" {
  type    = string
  default = "This is the first member"
}
variable "member_admin_username" {
  description = "The user name of your member's admin user."
}
variable "member_admin_password" {
  description = "The password of your member's admin user."
}

variable "peernode_instance_type" {
  description = "The type of compute instance to use for your peer nodes."
  default     = "bc.t3.small"
}

variable "blockchain_protocol_framework" {
  description = "The blockchain protocol to use, such as Hyperledger Fabric"
  default     = "HYPERLEDGER_FABRIC"
}
variable "blockchain_protocol_framework_version" {
  description = "The version of the blockchain protocol to use"
  default     = "2.2"
}

variable "vpc_id" {
  type = string
}
variable "ami_id" {
  description = "AMI ID for the EC2 cli"
}
variable "subnet_id" {
  type = string
}



variable "description" {
  default = "Blockchain instance"
}

variable "tag_name" {
  default = "BC cli EC2"
}

variable "bc_peer_node_count" {
  description = "Number of peer nodes associated with the network"
  type        = number
  default     = 1
}

variable "ec2_cli_configuration" {
  type = list(object({
    key_pair_name    = string,
    channel_id       = string,
    channel_codename = string
    instance_type    = string
  }))
}

variable "s3_uri_bc_code" {
  description = "S3 URI of the chain code"
}

variable "docker_file_path" {

}
variable "ecs_container_folder_path" {

}

variable "storage_bucket" {
}
