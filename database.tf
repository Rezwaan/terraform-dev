##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "mongodb_primary" {
    availability_zone = "${var.region}a"

    tags = {
        Name = "${var.environment}-mongodb-one"
    }

    ami = data.aws_ami.ubuntu.id

    instance_type = local.asg_instance_size

    root_block_device {
        volume_type = "gp2"
        volume_size = "30"
    }
    
    #subnet_id = aws_subnet.private[0].id
    subnet_id = module.private-subnet.subnet_id

    security_groups = [
        module.webapp_http_inbound_sg.security_group_id,
        module.webapp_ssh_inbound_sg.security_group_id,
        module.webapp_mongo_inbound_sg.security_group_id,
    ]

    associate_public_ip_address = false
    
    user_data                   = data.template_file.mongo-db-userdata.rendered

    key_name = aws_key_pair.homelike-key-pair.key_name
}