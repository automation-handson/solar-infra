locals {
  # List of addons that require IAM permissions via pod identity
  addons_require_permissions = {
    "vpc-cni" = {
      policy_arn      = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      service_account = "aws-node"
    }
    "aws-ebs-csi-driver" = {
      policy_arn      = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      service_account = "ebs-csi-controller-sa"
    }
  }

  # All required addons you we to install except the pod-identity-agent and the vpc-cni as they need a special order before
  # installing other addons
  all_addons = ["kube-proxy", "coredns", "aws-ebs-csi-driver"]
}

# Fetch versions for ALL addons that are compatible with the cluster version
data "aws_eks_addon_version" "eks_addon_compatible_versions" {
  for_each           = toset(concat(local.all_addons, ["eks-pod-identity-agent", "vpc-cni"]))
  addon_name         = each.value
  kubernetes_version = var.cluster_version
  most_recent        = true
}

# Deploy the Pod Identity Agent addon FIRST (required by other addons that need pod identity)
resource "aws_eks_addon" "pod_identity_addon" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.eks_addon_compatible_versions["eks-pod-identity-agent"].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# Create IAM Roles for addons that require pod identity
resource "aws_iam_role" "addon_roles" {
  for_each = local.addons_require_permissions
  name     = "${var.cluster_name}-${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

# Attach required policies to the addons IAM Roles based on the local map of addons
resource "aws_iam_role_policy_attachment" "addon_policy_attachment" {
  for_each   = local.addons_require_permissions
  policy_arn = each.value.policy_arn
  role       = aws_iam_role.addon_roles[each.key].name
}

# Associate the IAM Roles with the addons via Pod Identity Associations
resource "aws_eks_pod_identity_association" "associate_addons_roles_to_sa" {
  for_each        = local.addons_require_permissions
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = each.value.service_account
  role_arn        = aws_iam_role.addon_roles[each.key].arn
  depends_on = [ aws_eks_addon.pod_identity_addon, aws_iam_role_policy_attachment.addon_policy_attachment]
}

# install the vpc-cni as it's required by other addons
resource "aws_eks_addon" "vpc_cni_addons" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
  addon_version = data.aws_eks_addon_version.eks_addon_compatible_versions["vpc-cni"].version

  # Critical: Ensure the agent and identities are ready before starting the addons
  depends_on = [
    aws_eks_pod_identity_association.associate_addons_roles_to_sa
  ]
}

resource "aws_eks_addon" "installed_addons" {
  for_each     = toset(local.all_addons)
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = each.value

  # Critical: Ensure the agent and identities are ready before starting the addons
  depends_on = [
    aws_eks_pod_identity_association.associate_addons_roles_to_sa, aws_eks_addon.vpc_cni_addons
  ]
}
