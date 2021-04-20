output "subnet_id" {
  #value = aws_subnet.subnet.*.id
  value = aws_subnet.subnet[*].id
}

output "cidr_blocks" {
  value = aws_subnet.subnet[*].cidr_block
}
