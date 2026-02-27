# we output the role ARNs and their names as maps for easy reference as below:
# pod_identity_role_arns["vault"] => "arn:aws:iam::123456789012:role/eks-cluster-vault-pod-identity"
output "pod_identity_role_arns" {
  description = "Map of identity names to their IAM Role ARNs"
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}

output "pod_identity_role_names" {
  description = "Map of identity names to their IAM Role Names"
  value       = { for k, v in aws_iam_role.this : k => v.name }
}