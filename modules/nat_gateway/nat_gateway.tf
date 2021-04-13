/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_id
  subnet_id     = element(var.public_subnet.*.id, 0)
  depends_on    = [var.depend_on]
  tags = {
    Name        = var.tag_name
  }
}