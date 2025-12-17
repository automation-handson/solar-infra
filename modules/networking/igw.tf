resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name            = "${var.env_name}-igw"
  }
}

resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name            = "${var.env_name}-public-route-table"
  }
}

resource "aws_route_table_association" "eks_public_route_table_association" {
  for_each = {
    for subnet in local.public_nested_config : "${subnet.name}" => subnet
  }

  subnet_id      = aws_subnet.eks_public_subnets[each.value.name].id
  route_table_id = aws_route_table.eks_public_route_table.id
}