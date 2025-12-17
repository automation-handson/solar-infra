resource "aws_eip" "eks_eip" {
  tags = {
    Name            = "${var.env_name}-eip-main"
  }
}

resource "aws_nat_gateway" "eks_nat_gw" {

  allocation_id = aws_eip.eks_eip.id
  subnet_id     = aws_subnet.eks_public_subnets[keys(aws_subnet.eks_public_subnets)[0]].id

  tags = {
    Name            = "${var.env_name}-main-nat-gw"
  }
}

resource "aws_route_table" "eks_private_route_table" {
  
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gw.id
  }

  tags = {
    Name            = "${var.env_name}-private-route-table"
  }
}

resource "aws_route_table_association" "eks_private_route_table_association" {

  for_each = {
    for subnet in local.private_nested_config : "${subnet.name}" => subnet
  }

  subnet_id      = aws_subnet.eks_private_subnets[each.value.name].id
  route_table_id = aws_route_table.eks_private_route_table.id
}