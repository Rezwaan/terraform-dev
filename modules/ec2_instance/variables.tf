variable availability_zone {
  type    = string
  default = "us-east-1a"
}

variable tag {
  type    = string
  default = "database"
}

variable ami {
  type    = string
  default = "ubuntu-123"
}

variable instance_type {
  type    = string
  default = "t2.micro"
}

variable volume_type {
  type    = string
  default = "gp2"
}

variable volume_size {
  type    = string
  default = "30"
}

variable subnet_id {
  type    = string
  default = "0.0.0.0"
}

variable security_groups {
  type    = list
  default = ["0.0.0.0"]
}

variable associate_public_ip_address {
  type    = bool
  default = true
}

variable user_data {
  type    = string
  default = "userdata"
}

variable key_name {
  type    = string
  default = "homelike-key"
}