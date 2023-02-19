variable "prefix" {}
variable "network_name" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-zA-Z]+$", var.network_name))
    error_message = "Network name must be alphanumeric and cannot contain spaces."
  }
}
variable "network_description" {
  type = string
  description = "An optional description of your network."
}
variable "blockchain_edition" {
  type = string
  description = "Setting that determines the number of peer nodes per member and the selection of instance types that can be used for them."
  validation {
    condition = contains(["STARTER", "STANDARD"], var.blockchain_edition)
    error_message = "Valid value is one of the following: STARTER, STANDARD."
  }
}
variable "network_threshold_percentage" {
  description = "The percentage of favorable votes needed to approve a blockchain proposal."
  type = number
  validation {
    condition     = var.network_threshold_percentage > 0 && var.network_threshold_percentage < 101
    error_message = "Threshold percentage must be between 1 and 100."
  }

}
variable "network_threshold_comparator" {
  description = "This comparator is used to determine how the vote percentages are compared with the threshold. If it is GREATER_THAN, then the percentage of favorable votes must exceed the ThresholdPercentage for a proposal to pass. If it is GREATER_THAN_OR_EQUAL_TO, then the percentage of favorable votes must at least be equal to the threshold for a proposal to pass."
  validation {
    condition = contains(["GREATER_THAN", "GREATER_THAN_OR_EQUAL_TO"], var.network_threshold_comparator)
    error_message = "Valid value is one of the following: GREATER_THAN, GREATER_THAN_OR_EQUAL_TO."
  }

}
variable "network_proposal_duration_in_hours" {
  type = number
  description = "The number of hours a proposal can be voted on."
  validation {
    condition     = var.network_proposal_duration_in_hours > 0 && var.network_proposal_duration_in_hours < 169
    error_message = "Proposal duration must be between 1 and 168 hours."
  }
}


variable "member_name" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-zA-Z]+$", var.member_name))
    error_message = "Network name must be alphanumeric and cannot contain spaces."
  }
}
variable "member_description" {
  type = string
  description = "An optional description of your member."
}
variable "member_admin_username" {
  description = "The user name of your member's admin user."
  type = string
  validation {
    condition     = can(regex("^[0-9a-zA-Z]+$", var.member_admin_username))
    error_message = "admin username must be alphanumeric and cannot contain spaces."
  }
}
variable "member_admin_password" {
  description = "The password of your member's admin user."
  validation {
    condition = length(var.member_admin_password) >= 8 && length(var.member_admin_password) <= 32
    error_message = "Password length must be between 8 and 32."
  }

  validation {
    condition = can(regex("[A-Z]", var.member_admin_password))
    error_message = "Password must contain at least one uppercase letter."
  }

  validation {
    condition = can(regex("[a-z]", var.member_admin_password))
    error_message = "Password must contain at least one lowercase letter."
  }

  validation {
    condition = can(regex("[0-9]", var.member_admin_password))
    error_message = "Password must contain at least one digit."
  }


  validation {
    condition = !can(regex("['\"\\/ @]", var.member_admin_password))
    error_message = "Password  must not contain ', \", \\, /, @ or spaces"
  }
}
variable "peernode_availabilityzone" {
  type = string
  description = "The Availability Zone for the peer node."
}
variable "peernode_instance_type" {
  description = "The type of compute instance to use for your peer nodes."
  validation {
    condition = contains(["bc.t3.small","bc.t3.medium", "bc.t3.large", "bc.t3.xlarge", "bc.m5.large", "bc.m5.xlarge", "bc.m5.2xlarge", "bc.m5.4xlarge", "bc.c5.large", "bc.c5.xlarge", "bc.c5.2xlarge", "bc.c5.4xlarge"], var.peernode_instance_type)
    error_message = "Valid value is one of the following: bc.t3./bc.m5./bc.c5.(small/medium/large). If Edition is STARTER, then this value must be bc.t3.small or bc.t3.medium."
  }
}

variable "blockchain_protocol_framework" {
  description = "The blockchain protocol to use, such as Hyperledger Fabric"
}
variable "blockchain_protocol_framework_version" {
  description = "The version of the blockchain protocol to use"
}