variable "vpc_id" {

}

variable "ssh_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}
variable "tcp_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}
variable "prefix" {}