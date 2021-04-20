##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "ec2" {
    availability_zone           = var.availability_zone
    tags = {
        Name = var.tag
    }
    ami                         = var.ami
    instance_type               = var.instance_type
    root_block_device {
        volume_type = var.volume_type
        volume_size = var.volume_size
    }
    subnet_id                   = var.subnet_id
    security_groups             = var.security_groups
    associate_public_ip_address = var.associate_public_ip_address
    user_data                   = var.user_data
    key_name                    = var.key_name
}