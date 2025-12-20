output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "nat_gateway_public_ip" {
  value = aws_nat_gateway.nat_gw.public_ip
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
} 