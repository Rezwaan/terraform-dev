resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnets_cidr[count.index]
  count                   = length(var.subnets_cidr)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.tag_name
  }
  depends_on = [
    var.depend_on
  ]
}


/* Routing table for subnet */
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name        = var.tag_name
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = var.gateway_id
}

resource "aws_route_table_association" "route_association" {
  count          = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table.id
}
