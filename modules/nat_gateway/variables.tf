variable eip_id {
  type    = string
  default = "homelike-vpc"
}

variable public_subnet {
  type    = list
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable depend_on {
  type    = string
  default = "homelike-vpc"
}

variable tag_name {
  type    = string
  default = "NAT Gateway"
}