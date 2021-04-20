##################################################################################
# CONFIGURATION - added for Terraform 0.14
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile                 = "homelike"
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  #assume_role {
  #  role_arn             = "arn:aws:iam::848854301277:role/terraform-sts"
  #  session_name         = "home-like-dev"
  #}
  
}


module "homelike-vpc" {
  source                  = "./modules/vpc"

  vpc_cidr_block          = "10.0.0.0/16"
  vpc_dns_support         = true
  vpc_dns_hostnames       = true

}

module "homelike-igw" {
  source                  = "./modules/internet_gateway"

  vpc_id                  = module.homelike-vpc.vpc_id
  tag_name                = "internet Gateway"

}
### Elastic IP
module "homelike-eip" {
  source                  = "./modules/elastic_ip"

  depend_on               = module.homelike-vpc.vpc_id
  
}

### Nat Gateway
module "homelike-nat-gateway" {
  source                  = "./modules/nat_gateway"

  eip_id                  = module.homelike-eip.eip_id
  public_subnet           = module.public-subnet.subnet_id[0]
  depend_on               = module.homelike-igw.gateway_id
  tag_name                = "NAT Gateway"
  
}

### Public Subnet

module "public-subnet" {
  source                  = "./modules/subnet"

  vpc_id                  = module.homelike-vpc.vpc_id
  subnets_cidr            = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  availability_zones      = ["us-east-1a","us-east-1b","us-east-1c"]
  map_public_ip_on_launch = true
  tag_name                = "public subnet"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = module.homelike-igw.gateway_id
  depend_on               = module.homelike-igw.gateway_id

}

### Private Subnet

module "private-subnet" {
  source                  = "./modules/subnet"

  vpc_id                  = module.homelike-vpc.vpc_id
  subnets_cidr            = ["10.0.8.0/24","10.0.9.0/24","10.0.10.0/24"]
  availability_zones      = ["us-east-1a","us-east-1b","us-east-1c"]
  map_public_ip_on_launch = false
  tag_name                = "private subnet"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = module.homelike-nat-gateway.nat_gateway_id
  depend_on               = module.homelike-igw.gateway_id

}

### Security Groups
module "default-sg" {
  source                  = "./modules/security-group"
  name                    = "default-sg"
  description             = "Default security group to allow inbound/outbound from the VPC"
  ingress_from_port       = 0
  ingress_to_port         = 0
  ingress_protocol        = -1
  self                    = true
  egress_from_port        = 0
  egress_to_port          = 0
  egress_protocol         = -1
  vpc_id                  = module.homelike-vpc.vpc_id
  tag_name                = "Default Security Groups"

}


### Security Groups Web Inbound
module "webapp_http_inbound_sg" {
  source                  = "./modules/security-group"
  name                    = "demo_webapp_http_inbound"
  description             = "Allow HTTP from Anywhere"
  ingress_from_port       = 80
  ingress_to_port         = 80
  ingress_protocol        = "tcp"
  ingress_cidr_block      = ["0.0.0.0/0"]
  egress_from_port        = 0
  egress_to_port          = 0
  egress_protocol         = "-1"
  egress_cidr_block       = ["0.0.0.0/0"]
  vpc_id                  = module.homelike-vpc.vpc_id
  tag_name                = "demo_webapp_http_inbound"

}

### Security Groups SSH Inbound
module "webapp_ssh_inbound_sg" {
  source                  = "./modules/security-group"
  name                    = "demo_webapp_ssh_inbound"
  description             = "Allow SSH from certain ranges"
  ingress_from_port       = 22
  ingress_to_port         = 22
  ingress_protocol        = "tcp"
  ingress_cidr_block      = ["0.0.0.0/0"]
  egress_from_port        = 22
  egress_to_port          = 22
  egress_protocol         = "tcp"
  egress_cidr_block       = ["0.0.0.0/0"]
  vpc_id                  = module.homelike-vpc.vpc_id
  tag_name                = "demo_webapp_ssh_inbound"

}

### Security Groups MongoDB
module "webapp_mongo_inbound_sg" {
  source                  = "./modules/security-group"
  name                    = "demo_webapp_mongo_inbound"
  description             = "Allow MongoDB from certain ranges"
  ingress_from_port       = 27017
  ingress_to_port         = 27017
  ingress_protocol        = "tcp"
  ingress_cidr_block      = module.public-subnet.cidr_blocks
  egress_from_port        = 27017
  egress_to_port          = 27017
  egress_protocol         = "tcp"
  egress_cidr_block       = module.public-subnet.cidr_blocks
  vpc_id                  = module.homelike-vpc.vpc_id
  tag_name                = "demo_webapp_mongo_inbound"

}


### Security Groups MongoDB Replication
module "webapp_mongo_replication_inbound_sg" {
  source                  = "./modules/security-group"
  name                    = "demo_webapp_mongo_replication_inbound"
  description             = "Allow MongoDB Replication from certain ranges"
  ingress_from_port       = 27019
  ingress_to_port         = 27019
  ingress_protocol        = "tcp"
  ingress_cidr_block      = module.public-subnet.cidr_blocks
  egress_from_port        = 27019
  egress_to_port          = 27019
  egress_protocol         = "tcp"
  egress_cidr_block       = module.public-subnet.cidr_blocks
  vpc_id                  = module.homelike-vpc.vpc_id
  tag_name                = "demo_webapp_mongo_replication_inbound"

}

### Elastic Load Balancer for Node Servers
module "elb" {
  source                  = "./modules/elastic_load_balancer"
  
  elb_name                = "node-lb"
  subnets                 = module.public-subnet.subnet_id
  instance_protocol       = "http"
  instance_port           = 80
  load_balancer_protocol  = "http"
  load_balancer_port      = 80
  health_check_target     = "HTTP:80/"
  security_groups         = [module.webapp_http_inbound_sg.security_group_id]
}

### S3 Logging Bucket
module "s3_bucket" {
  source                  = "./modules/s3"

  aws_bucket_prefix       = "homelike-log"

}

### AWS Instance Profile for ASG
module "instance_profile" {
  source                  = "./modules/instance_profile"

  bucket_name             = module.s3_bucket.bucket_name   
}

### AWS Key Pair for ec2 instances
module "key_pair" {
  source                  = "./modules/key_pair"
  key_name                = "homelike-key"
  public_key              = "${file("C:\\Users\\devops\\Documents\\hl-keys\\homelike.pem")}"
}

### AutoScaling Group for Node servers
module "node_autoscaling_group" {
  source                    = "./modules/autoscaling_group"

  is_classic_load_balancer  = true
  lc-name-prefix            = "node-asg"
  image_id                  = data.aws_ami.ubuntu.id
  instance_type             = "t2.micro"
  security_groups           = [module.webapp_http_inbound_sg.security_group_id,module.webapp_ssh_inbound_sg.security_group_id]
  lc-associate_public_ip_address-prefix = true
  key_name                  = module.key_pair.key_name
  subnet_id                 = module.public-subnet.subnet_id
  asg_name                  = "node-asg"
  maximum_instances         = 3
  minimum_instances         = 2
  load_balancers            = [module.elb.elb_name]
  iam_instance_profile      = module.instance_profile.profile_name
  data                      = data.template_file.node-userdata.rendered
  tag_name                  = "node-servers"
}



### Application Load Balancer for NGINX servers
module "alb" {
  source                    = "./modules/load_balancer"

  alb_name                  = "nginx-lb"
  lb_type                   = "application"
  security_groups           = [module.webapp_http_inbound_sg.security_group_id,module.webapp_ssh_inbound_sg.security_group_id]
  subnets                   = module.public-subnet.subnet_id
  target_group_name         = "nginx-target-group"
  target_group_port         = 80
  target_group_protocol     = "HTTP"
  vpc_id                    = module.homelike-vpc.vpc_id
  listener_port             = 80
  listener_protocol         = "HTTP"
}

### AutoScaling Group for NGINX servers
module "nginx_autoscaling_group" {
  source                                = "./modules/autoscaling_group"

  is_classic_load_balancer              = false
  lc-name-prefix                        = "nginx-asg"
  image_id                              = data.aws_ami.ubuntu.id
  instance_type                         = "t2.micro"
  security_groups                       = [module.webapp_http_inbound_sg.security_group_id,module.webapp_ssh_inbound_sg.security_group_id]
  lc-associate_public_ip_address-prefix = true
  key_name                              = module.key_pair.key_name
  subnet_id                             = module.public-subnet.subnet_id
  asg_name                              = "nginx-asg"
  maximum_instances                     = 3
  minimum_instances                     = 2
  target_group_arns                     = [module.alb.target_group_arn]
  iam_instance_profile                  = module.instance_profile.profile_name
  data                                  = data.template_file.nginx-userdata.rendered
  tag_name                              = "web-servers"
}

### ec2 instances for Database
module "database_instance" {
  source                              = "./modules/ec2_instance"

  availability_zone                   = "us-east-1a"
  ami                                 = data.aws_ami.ubuntu.id
  tag                                 = "database-instance"
  instance_type                       = "t2.micro"
  volume_type                         = "gp2"
  volume_size                         = "30"
  subnet_id                           = module.private-subnet.subnet_id[0]
  security_groups = [
        module.webapp_mongo_inbound_sg.security_group_id,
        module.webapp_mongo_replication_inbound_sg.security_group_id,
        module.webapp_ssh_inbound_sg.security_group_id
    ]
  associate_public_ip_address         = false
  user_data                           = data.template_file.mongo-db-userdata.rendered
  key_name                            = module.key_pair.key_name
}

### ec2 instances for VPN
module "vpn_instance" {
  source                              = "./modules/ec2_instance"

  availability_zone                   = "us-east-1a"
  ami                                 = data.aws_ami.ubuntu.id
  tag                                 = "vpn-instance"
  instance_type                       = "t2.micro"
  volume_type                         = "gp2"
  volume_size                         = "30"
  subnet_id                           = module.public-subnet.subnet_id[0]
  security_groups = [
        module.webapp_ssh_inbound_sg.security_group_id,
        module.webapp_http_inbound_sg.security_group_id
    ]
  associate_public_ip_address         = true
  user_data                           = data.template_file.openvpn-userdata.rendered
  key_name                            = module.key_pair.key_name
}
