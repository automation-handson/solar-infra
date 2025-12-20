resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_name}-vpc"
  }

}

# for managing main rtb and put vf tags
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${var.env_name}-default-route-table"
  }
}

resource "aws_default_security_group" "default_security_group" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env_name}-default-security-group"
  }
}