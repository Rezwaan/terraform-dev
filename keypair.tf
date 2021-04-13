#resource "tls_private_key" "homelike" {
#  algorithm = "RSA"
#}


# Creating a New Key
resource "aws_key_pair" "homelike-key-pair" {
key_name   = "homelike-key"

  public_key = "${file("C:\\Users\\devops\\Documents\\hl-keys\\homelike.pem")}"
  
 }
