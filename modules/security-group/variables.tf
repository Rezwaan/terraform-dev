variable name {
  type    = string
  default = "subnet"
}

variable description {
  type    = string
  default = "subnet"
}

variable ingress_from_port {
  type    = string
  default = "subnet"
}

variable ingress_to_port {
  type    = string
  default = "subnet"
}

variable ingress_protocol {
  type    = string
  default = "subnet"
}

variable ingress_cidr_block {
  type    = list
  default = ["0.0.0.0/0"]
}

variable egress_from_port {
  type    = string
  default = "subnet"
}

variable egress_to_port {
  type    = string
  default = "subnet"
}

variable egress_protocol {
  type    = string
  default = "subnet"
}

variable egress_cidr_block {
  type    = list
  default = ["0.0.0.0/0"]
}

variable vpc_id {
  type    = string
  default = "homelike-vpc"
}

variable tag_name {
  type    = string
  default = "homelike-vpc"
}
variable self {
  type    = bool
  default = false
}