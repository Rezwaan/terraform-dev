##################################################################################
# CONFIGURATION - added for Terraform 0.14
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "homelike"
  region  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  assume_role {
    role_arn     = "arn:aws:iam::848854301277:role/terraform-sts"
    session_name = "home-like-dev"
  }
  
}


module "homelike-vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"
  vpc_dns_support= true
  vpc_dns_hostnames= true

}

module "homelike-igw" {
  source = "./modules/internet_gateway"

  vpc_id = module.homelike-vpc.vpc_id
  tag_name = "internet Gateway"

}
### Elastic IP
module "homelike-eip" {
  source = "./modules/elastic_ip"

  depend_on = module.homelike-vpc.vpc_id
  
}

### Nat Gateway
module "homelike-nat-gateway" {
  source = "./modules/nat_gateway"

  eip_id = module.homelike-eip.eip_id
  public_subnet = module.public-subnet.subnet_id
  depend_on = module.homelike-igw.gateway_id
  tag_name = "NAT Gateway"
  
}

### Public Subnet

module "public-subnet" {
  source = "./modules/subnet"

  vpc_id = module.homelike-vpc.vpc_id
  subnets_cidr = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
  map_public_ip_on_launch = true
  tag_name = "public subnet"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = module.homelike-igw.gateway_id
  depend_on = module.homelike-igw.gateway_id

}

### Private Subnet

module "private-subnet" {
  source = "./modules/subnet"

  vpc_id = module.homelike-vpc.vpc_id
  subnets_cidr = ["10.0.8.0/24","10.0.9.0/24","10.0.10.0/24"]
  availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
  map_public_ip_on_launch = false
  tag_name = "private subnet"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = module.homelike-nat-gateway.nat_gateway_id
  depend_on = module.homelike-igw.gateway_id

}

### Security Groups
module "default-sg" {
  source = "./modules/security-group"
  name = "default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  ingress_from_port = 0
  ingress_to_port = 0
  ingress_protocol = -1
  self = true
  egress_from_port = 0
  egress_to_port = 0
  egress_protocol = -1
  vpc_id = module.homelike-vpc.vpc_id
  tag_name = "Default Security Groups"

}


### Security Groups Web Inbound
module "webapp_http_inbound_sg" {
  source = "./modules/security-group"
  name = "demo_webapp_http_inbound"
  description = "Allow HTTP from Anywhere"
  ingress_from_port = 80
  ingress_to_port = 80
  ingress_protocol = "tcp"
  ingress_cidr_block = ["0.0.0.0/0"]
  egress_from_port = 80
  egress_to_port = 80
  egress_protocol = "tcp"
  egress_cidr_block = ["0.0.0.0/0"]
  vpc_id = module.homelike-vpc.vpc_id
  tag_name = "demo_webapp_http_inbound"

}

### Security Groups SSH Inbound
module "webapp_ssh_inbound_sg" {
  source = "./modules/security-group"
  name = "demo_webapp_ssh_inbound"
  description = "Allow SSH from certain ranges"
  ingress_from_port = 22
  ingress_to_port = 22
  ingress_protocol = "tcp"
  ingress_cidr_block = ["0.0.0.0/0"]
  egress_from_port = 22
  egress_to_port = 22
  egress_protocol = -1
  egress_cidr_block = ["0.0.0.0/0"]
  vpc_id = module.homelike-vpc.vpc_id
  tag_name = "demo_webapp_ssh_inbound"

}

### Security Groups MongoDB
module "webapp_mongo_inbound_sg" {
  source = "./modules/security-group"
  name = "demo_webapp_mongo_inbound"
  description = "Allow MongoDB from certain ranges"
  ingress_from_port = 27017
  ingress_to_port = 27017
  ingress_protocol = "tcp"
  ingress_cidr_block = module.public-subnet.subnet_id
  egress_from_port = 27017
  egress_to_port = 27017
  egress_protocol = -1
  egress_cidr_block = module.public-subnet.subnet_id
  vpc_id = module.homelike-vpc.vpc_id
  tag_name = "demo_webapp_mongo_inbound"

}


### Security Groups MongoDB Replication
module "webapp_mongo_replication_inbound_sg" {
  source = "./modules/security-group"
  name = "demo_webapp_mongo_replication_inbound"
  description = "Allow MongoDB Replication from certain ranges"
  ingress_from_port = 27019
  ingress_to_port = 27019
  ingress_protocol = "tcp"
  ingress_cidr_block = module.public-subnet.subnet_id
  egress_from_port = 27019
  egress_to_port = 27019
  egress_protocol = -1
  egress_cidr_block = module.public-subnet.subnet_id
  vpc_id = module.homelike-vpc.vpc_id
  tag_name = "demo_webapp_mongo_replication_inbound"

}




