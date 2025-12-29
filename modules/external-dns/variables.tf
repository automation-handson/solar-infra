variable "chart_version" {
  type        = string
  description = "external-dns helm chart version"
  default     = "1.19.0"
}

variable "aws_region" {
  type        = string
  description = "The region when the EKS is installed"
  default     = "eu-central-1"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}