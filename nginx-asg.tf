##################################################################################
# RESOURCES
##################################################################################

resource "aws_launch_configuration" "nginx-lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = "nginx-lc"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = local.asg_instance_size

  security_groups = [
    module.webapp_http_inbound_sg.security_group_id,
    module.webapp_ssh_inbound_sg.security_group_id,
  ]

  user_data                   = data.template_file.nginx-userdata.rendered
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.asg.name
  key_name = aws_key_pair.homelike-key-pair.key_name
}




resource "aws_autoscaling_group" "nginx_asg" {
  lifecycle {
    create_before_destroy = false
  }

  #vpc_zone_identifier   = [aws_subnet.public[0].id,aws_subnet.public[1].id,aws_subnet.public[2].id]
  vpc_zone_identifier   = module.public-subnet.subnet_id
  name                  = "homelike_nginx_asg-${terraform.workspace}"
  max_size              = local.asg_max_size
  min_size              = local.asg_min_size
  force_delete          = true
  launch_configuration  = aws_launch_configuration.nginx-lc.id
  #load_balancers        = [aws_alb.nginx_alb.name]
  target_group_arns     = ["${aws_lb_target_group.nginx-lbtg.arn}"]

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  tag {
    key                 = "Name"
    value               = "Nginx Server"
    propagate_at_launch = true
  }
}

#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "nginx_scale_up" {
  name                   = "homelike_asg_nginx_scale_up-${terraform.workspace}"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.name
}

resource "aws_cloudwatch_metric_alarm" "nginx_scale_up_alarm" {
  alarm_name                = "ddt-high-asg-cpu-${terraform.workspace}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nginx_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = [aws_autoscaling_policy.nginx_scale_up.arn]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "nginx_scale_down" {
  name                   = "homelike_asg_nginx_scale_down-${terraform.workspace}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.name
}

resource "aws_cloudwatch_metric_alarm" "nginx_scale_down_alarm" {
  alarm_name                = "ddt-low-asg-cpu-${terraform.workspace}"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nginx_asg.name
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = [aws_autoscaling_policy.nginx_scale_down.arn]
}