# create the VPC
resource "aws_vpc" "homelike-dev-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default" 
  enable_dns_support   = var.vpc_dns_support
  enable_dns_hostnames = var.vpc_dns_hostnames
tags = {
    Name = "Homelike VPC"
}
}