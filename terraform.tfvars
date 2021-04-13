//AWS 
region      = "us-east-1"
environment = "development"
availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
private_subnets_cidr = ["10.0.8.0/24","10.0.9.0/24","10.0.10.0/24"]