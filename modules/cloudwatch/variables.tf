variable scale_up_policy_name {
  type    = string
  default = "homelike-scale"
}

variable autoscaling_group_name {
  type    = string
  default = "homelike-asg"
}

variable scale_up_alarm_name {
  type    = string
  default = "homelike-asg-alarm"
}

variable scale_down_policy_name {
  type    = string
  default = "homelike-scale"
}

variable scale_down_alarm_name {
  type    = string
  default = "homelike-asg-alarm"
}

variable depend_on {
  type    = string
  default = "homelike-asg-alarm"
}