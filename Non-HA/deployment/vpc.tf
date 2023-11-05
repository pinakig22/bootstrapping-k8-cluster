################################################################################
# Author      : Pinaki Ghosh
# Date Created: 05 Nov 2023
################################################################################
resource "aws_eip" "nat-gw" {
  count = var.multiple_nat_gw ? length(var.azs) : 1
  domain = "vpc"

  tags = {
    Name = "k8-non-ha-cluster-nat-gw-eip"
    Terraform = "true"
    Environment = "testing"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "k8-non-ha-cluster-vpc"
  cidr = var.vpc_cidr

  azs = var.azs
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = !var.multiple_nat_gw

  enable_dns_hostnames = true
  enable_dns_support   = true
  external_nat_ip_ids = aws_eip.nat-gw.*.id

    tags = {
    Terraform = "true"
    Environment = "testing"
  }

  private_subnet_tags = {
    Name = "k8-non-ha-cluster-private-subnet"
    Private = "true"
    Terraform = "true"
  }

  public_subnet_tags = {
    Name = "k8-non-ha-cluster-public-subnet"
    Private = "false"
    Terraform = "true"
  }

}