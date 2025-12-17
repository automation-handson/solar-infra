resource "aws_security_group" "eks_cluster" {
  name        = "ControlPlaneSecurityGroup"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = aws_vpc.security.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name            = "vault-nonprod-cluster/ControlPlaneSecurityGroup"
    Environment     = "SANDBOX"
    Project         = "vf-grp-ias-dev-ias-sanbox"
    ManagedBy       = "o-380-dl-vci-secretsmanagement@vodafone.onmicrosoft.com"
    SecurityZone    = "DEV"
    Confidentiality = "C2"
    TaggingVersion  = "V2.4"
  }
}
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow unmanaged nodes to communicate with control plane (all ports)"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_eks_cluster.eks-test-cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 0
  type                     = "ingress"
}
resource "aws_security_group" "eks_nodes" {
  name        = "ClusterSharedNodeSecurityGroup"
  description = "Communication between all nodes in the cluster"
  vpc_id      = aws_vpc.security.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_eks_cluster.eks-test-cluster.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name            = "vault-nonprod-cluster/ClusterSharedNodeSecurityGroup"
    Environment     = "SANDBOX"
    Project         = "vf-grp-ias-dev-ias-sanbox"
    ManagedBy       = "o-380-dl-vci-secretsmanagement@vodafone.onmicrosoft.com"
    SecurityZone    = "DEV"
    Confidentiality = "C2"
    TaggingVersion  = "V2.4"
  }
}