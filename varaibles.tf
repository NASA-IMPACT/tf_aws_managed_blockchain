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
  default = "This is a member"
}
variable "member_admin_username" {
  description = "The user name of your member's admin user."

}
variable "member_admin_password" {
  description = "The password of your member's admin user."

}

variable "peernode_instance_type" {
  description = "The type of compute instance to use for your peer nodes."
}

variable "blockchain_protocol_framework" {
  description = "The blockchain protocol to use, such as Hyperledger Fabric"
  default     = "HYPERLEDGER_FABRIC"
}
variable "blockchain_protocol_framework_version" {
  description = "The version of the blockchain protocol to use"
  default     = "2.2"
}

variable "ami_id" {
  description = "AMI ID for the EC2 cli"

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
  default     = "s3://bc-chaincode-package/final.tar.gz" # Delete
}
#

variable "ecs_container_folder_path" {
}
#
variable "storage_bucket" {

}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}



variable "public_subnet_1_cidr" {
  description = "Public Subnet CIDR 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Public Subnet CIDR 2"
  default     = "10.0.2.0/24"
}

variable "public_subnet_3_cidr" {
  description = "Public Subnet CIDR 3"
  default     = "10.0.3.0/24"
}


variable "private_subnet_1_cidr" {
  description = "private Subnet CIDR 1"
  default     = "10.0.4.0/24"
}


variable "private_subnet_2_cidr" {
  description = "private Subnet CIDR 2"
  default     = "10.0.5.0/24"
}

variable "private_subnet_3_cidr" {
  description = "private Subnet CIDR 3"
  default     = "10.0.6.0/24"
}

variable "ecs_domain_name" {

}

variable "internet_cider_blocks" {
  default = "0.0.0.0/0"
}

variable "ecs-cluster-name" {
}

variable "docker_container_port" {
  default = 3000
}


variable "efs_path" {
  default = "/mnt/efs_mount"
}

variable "tasks_count" {
  default = "1"
}

variable "task_memory" {
  default = 1024
}

variable "ecs_environment" {
  type = list(object({ name = string, value = string }))
  default = [{
    name  = "EXAMPLE",
    value = "foo"
  }]
}
variable "key_name" {
  default = null
}


variable "docker_file_path" {
  type = string
}