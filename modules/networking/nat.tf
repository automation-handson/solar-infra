resource "aws_eip" "eip" {
  tags = {
    Name = "${var.env_name}-eip-main"
  }
}

resource "aws_nat_gateway" "nat_gw" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id

  tags = {
    Name = "${var.env_name}-main-nat-gw"
  }
}

resource "aws_route_table" "private_route_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.env_name}-private-route-table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {

  for_each = {
    for subnet in local.private_nested_config : "${subnet.name}" => subnet
  }

  subnet_id      = aws_subnet.private_subnets[each.value.name].id
  route_table_id = aws_route_table.private_route_table.id
}