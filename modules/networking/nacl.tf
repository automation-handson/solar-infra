resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = concat([for subnet in aws_subnet.private_subnets : subnet.id],
  [for subnet in aws_subnet.public_subnets : subnet.id])

  tags = {
    Name = "${var.env_name}-nacl"
  }
}

resource "aws_network_acl_rule" "nacl_inbound" {
  for_each = var.ingress_nacl_rules
  egress   = false # false means Inbound

  network_acl_id = aws_network_acl.nacl.id
  rule_number    = each.key
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "nacl_outbound" {
  for_each = var.egress_nacl_rules
  egress   = true # This makes it an Outbound rule

  network_acl_id = aws_network_acl.nacl.id
  rule_number    = each.key
  protocol       = each.value.protocol # "-1" means all protocols (TCP, UDP, ICMP, etc.)
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block

  # When protocol is -1 (all), port ranges are set to 0
  from_port = each.value.from_port
  to_port   = each.value.to_port
}