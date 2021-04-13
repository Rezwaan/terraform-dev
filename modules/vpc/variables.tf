variable vpc_cidr_block {
  type    = string
  default = "10.0.0.0/16"
}

variable vpc_dns_support {
  type    = string
  default = "true"
}

variable vpc_dns_hostnames {
  type    = string
  default = "true"
}
