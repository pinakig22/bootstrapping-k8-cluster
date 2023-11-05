################################################################################
# Author      : Pinaki Ghosh
# Date Created: 05 Nov 2023
################################################################################

aws_region = "ap-south-1"
azs = ["ap-south-1a","ap-south-1b","ap-south-1c"]
vpc_cidr = "10.1.0.0/24"

private_subnets = ["10.1.0.0/27", "10.1.0.32/27", "10.1.0.64/27"]
public_subnets = ["10.1.0.96/27", "10.1.0.128/27", "10.1.0.160/27"]

# keep this false for home/test setup to avoid high cost
multiple_nat_gw = false
