resource "aws_eks_access_entry" "admins_eks_access_entry" {
  for_each      = toset(var.eks_access_entry_users_list)
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admins_eks_access_entry_association" {
  for_each      = toset(var.eks_access_entry_users_list)
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = var.eks_access_entry_policy_arn
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.admins_eks_access_entry]
}