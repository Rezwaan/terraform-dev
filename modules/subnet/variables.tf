variable vpc_id {
  type    = string
  default = "homelike-vpc"
}

variable subnets_cidr {
  type    = list
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable availability_zones {
  type    = list
  default = ["us-east-1a","us-east-1b","us-east-1c"]
}

variable map_public_ip_on_launch {
  type    = string
  default = "true"
}

variable tag_name {
  type    = string
  default = "subnet"
}

variable destination_cidr_block {
  type    = string
  default = "0.0.0.0/0"
}

variable gateway_id {
  type    = string
  default = "default"
}
variable depend_on {
  type    = string
  default = "homelike-vpc"
}
variable public_subnet {
  description = "If set to true, It will be considered as public subnet otherwise private subnet"
  type    = bool
  default = "true"
}