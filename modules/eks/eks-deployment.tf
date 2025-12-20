# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.env_name}-${var.cluster_name}"
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_version

  access_config {
    authentication_mode = var.eks_access_config
  }

  bootstrap_self_managed_addons = true # Enable self-managed addons for better control over addon versions (kube-proxy, coredns, vpc-cni)

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.authorized_source_ranges     # Restrict access to specific CIDR blocks to kubectl commands
    subnet_ids              = var.eks_control_plane_subnet_ids # where the AWS Managed EKS Control Plane (through managed ENIs) will be deployed
  }

  enabled_cluster_log_types = var.eks_enabled_cluster_log_types


  tags = {
    Name = "${var.env_name}-${var.cluster_name}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]

}

# Node Group
resource "aws_eks_node_group" "node_group_cluster" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.env_name}-${var.cluster_name}-${var.eks_node_group_name}"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = var.eks_worker_node_subnet_ids # where the worker nodes will be deployed
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Name = "${var.env_name}-${var.cluster_name}-${var.eks_node_group_name}"
  }
}

# Tag Auto Scaling Group created by EKS Node Group
resource "aws_autoscaling_group_tag" "test_cluster_asg_tag" {
  for_each               = var.common_tags
  autoscaling_group_name = aws_eks_node_group.node_group_cluster.resources[0].autoscaling_groups[0].name
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}