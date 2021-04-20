#resource "tls_private_key" "homelike" {
#  algorithm = "RSA"
#}


# Creating a New Key
resource "aws_key_pair" "homelike-key-pair" {
#key_name   = "homelike-key"
key_name   = var.key_name

  #public_key = "${file("C:\\Users\\devops\\Documents\\hl-keys\\homelike.pem")}"
  public_key = var.public_key
  
 }
