locals {
  private_nested_config = flatten([
    for name, config in var.private_network_config : [
      {
        name                     = name
        cidr_block               = config.cidr_block
        associated_public_subnet = config.associated_public_subnet
      }
    ]
  ])
}

locals {
  public_nested_config = flatten([
    for name, config in var.public_network_config : [
      {
        name       = name
        cidr_block = config.cidr_block
      }
    ]
  ])
}

resource "aws_subnet" "eks_private_subnets" {
  for_each = {
    for subnet in local.private_nested_config : "${subnet.name}" => subnet
  }

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = var.az[index(local.private_nested_config, each.value)]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.env_name}-${each.value.name}"
    "kubernetes.io/role/internal-elb" = 1
  }

}

resource "aws_subnet" "eks_public_subnets" {
  for_each = {
    for subnet in local.public_nested_config : "${subnet.name}" => subnet
  }

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = var.az[index(local.public_nested_config, each.value)]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.env_name}-${each.value.name}"
    "kubernetes.io/role/elb" = 1
  }

}
