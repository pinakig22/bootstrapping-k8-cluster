################################################################################
# Author      : Pinaki Ghosh
# Date Created: 21 Nov 2023
################################################################################
variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "azs" {}

variable "vpc_cidr" {}

variable "private_subnets" {}

variable "public_subnets" {}

variable "multiple_nat_gw" {
  type = bool
  default = false
}

variable "bastion_ami" {
  description = "AMI ID in ap-south-1"
}

variable "bastion_inst_type" {
  description = "Bastion instance type"
}

variable "k8_ami" {
  description = "AMI ID for control and worker node in ap-south-1"
}

variable "control_inst_type" {
  description = "Control Plane Instance Type"
}

variable "worker_inst_type" {
  description = "Control Plane Instance Type"
}