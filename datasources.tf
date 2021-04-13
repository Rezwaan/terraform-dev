data "template_file" "nginx-userdata" {
  template = file("templates/nginx/userdata.sh")

  vars = {
    playbook_repository = var.playbook_repository
  }
}

data "template_file" "node-userdata" {
  template = file("templates/node/userdata.sh")

  vars = {
    playbook_repository = var.playbook_repository
  }
}

data "template_file" "mongo-db-userdata" {
  template = file("templates/mongo-db/userdata.sh")

  vars = {
    playbook_repository = var.playbook_repository
  }
}

/*data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "homelike-state"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
    profile = "homelike"
    shared_credentials_file = "~/.aws/credentials"
  }
}*/

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
