variable alb_name {
  type    = string
  default = "nginx-lb"
}

variable lb_type {
  type    = string
  default = "nginx-lb"
}
variable security_groups {
  type    = list
  default = ["nginx-lb"]
}

variable subnets {
  type    = list
  default = ["nginx-lb"]
}

variable target_group_name {
  type    = string
  default = "nginx-lb"
}

variable target_group_port {
  type    = number
  default = 80
}

variable target_group_protocol {
  type    = string
  default = "http"
}

variable vpc_id {
  type    = string
  default = "http"
}

variable listener_port {
  type    = number
  default = 80
}
variable listener_protocol {
  type    = string
  default = "http"
}