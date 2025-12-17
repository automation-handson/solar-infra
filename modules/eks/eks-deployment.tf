
# Test Cluster
# EKS Cluster
resource "aws_eks_cluster" "eks-test-cluster" {
  name     = "Test-cluster"
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = concat([var.authorized_source_ranges], ["${aws_eip.nat.public_ip}/32"])
    # public_access_cidrs     = concat([var.authorized_source_ranges], [for n in aws_eip.nat : "${n.public_ip}/32"])
    subnet_ids = concat([for s in aws_subnet.private : s.id], [for s in aws_subnet.public : s.id])
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  tags = {
    Environment     = "SANDBOX"
    Project         = "vf-grp-ias-dev-ias-sanbox"
    ManagedBy       = "o-380-dl-vci-secretsmanagement@vodafone.onmicrosoft.com"
    SecurityZone    = "DEV"
    Confidentiality = "C2"
    TaggingVersion  = "V2.4"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]

}

data "tls_certificate" "test-cluster" {
  url = aws_eks_cluster.eks-test-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "openid-test-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.test-cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-test-cluster.identity[0].oidc[0].issuer
  tags = {
    Environment     = "SANDBOX"
    Project         = "vf-grp-ias-dev-ias-sanbox"
    ManagedBy       = "o-380-dl-vci-secretsmanagement@vodafone.onmicrosoft.com"
    SecurityZone    = "DEV"
    Confidentiality = "C2"
    TaggingVersion  = "V2.4"
  }
}

# Node Group
resource "aws_eks_node_group" "node-group-test-cluster" {
  cluster_name    = aws_eks_cluster.eks-test-cluster.name
  node_group_name = "test-cluster-NG"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Environment     = "SANDBOX"
    Project         = "vf-grp-ias-dev-ias-sanbox"
    ManagedBy       = "o-380-dl-vci-secretsmanagement@vodafone.onmicrosoft.com"
    SecurityZone    = "DEV"
    Confidentiality = "C2"
    TaggingVersion  = "V2.4"
  }
}



locals {
  asg_tags = {
    Environment     = "SANDBOX"
    Project         = "vf-grp-ias-dev-ias-sanbox"
    ManagedBy       = "o-380-dl-vci-secretsmanagement@vodafone.onmicrosoft.com"
    SecurityZone    = "DEV"
    Confidentiality = "C2"
    TaggingVersion  = "V2.4"
  }
}

resource "aws_autoscaling_group_tag" "test-cluster_asg_tag" {
  for_each               = local.asg_tags
  autoscaling_group_name = aws_eks_node_group.node-group-test-cluster.resources[0].autoscaling_groups[0].name
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}