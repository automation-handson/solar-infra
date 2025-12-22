output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
output "eks_host" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}