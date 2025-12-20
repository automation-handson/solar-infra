# 1. Fetch versions for ALL required addons
data "aws_eks_addon_version" "eks_addon_compatible_versions" {
  for_each           = toset(concat(var.eks_addons, ["eks-pod-identity-agent"]))
  addon_name         = each.value
  kubernetes_version = var.cluster_version
  most_recent        = true
}

# 2. Deploy the Pod Identity Agent FIRST (Crucial for the VPC-CNI to use it)
resource "aws_eks_addon" "pod_identity_addon" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.eks_addon_compatible_versions["eks-pod-identity-agent"].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# 3. Deploy the core addons
resource "aws_eks_addon" "core_addons" {
  for_each      = toset(var.eks_addons)
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = each.value
  addon_version = data.aws_eks_addon_version.eks_addon_compatible_versions[each.value].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # Ensure Pod Identity Agent is actually running before VPC-CNI tries to use it
  depends_on = [aws_eks_addon.pod_identity_addon]
}

# 3. Associate the VPC-CNI IAM Role with the VPC-CNI addon via Pod Identity
resource "aws_eks_pod_identity_association" "vpc_cni_pod_identity_association" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "aws-node" # This is the standard vpc-cni service account
  role_arn        = aws_iam_role.vpc_cni_pod_identity_role.arn
  depends_on      = [aws_iam_role.vpc_cni_pod_identity_role]
} 