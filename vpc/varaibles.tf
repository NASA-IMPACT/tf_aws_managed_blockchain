variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "enable_dns_support" {
  default = True
}
variable "enable_dns_hostnames" {
  default = True
}
variable "instance_tenancy" {
  default = "default"
}
variable "tags" {
  type = list(object({}))
  default = [
    {
      Key = "Name"
      Value = "Blockchain VPC"
    }
  ]
}

variable "map_public_ip_on_launch" {
  default = False
}
variable "pub_subnet_cidr_block" {
  default = "10.0.0.0/18"
}