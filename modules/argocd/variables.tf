variable "chart_version" {
  type        = string
  default     = "7.7.0"
  description = "Argocd chart version"
}

variable "ingress_tags" {
  description = "Tags to be added to all resources for auditing or cost management"
  type        = map(string)
}

variable "avp_version" {
  type        = string
  default     = "1.18.0"
  description = "Argocd Vault plugin version"
}
variable "domain_name" {
  type        = string
  description = "The domain name from which argocd is accessible"
}

variable "ingress_class_name" {
  type        = string
  description = "The Ingress class name that will be used by argocd for the ingress resource"
}

variable "ingress_group_name" {
  type        = string
  description = "The Ingress group name that will be used by argocd for the ingress resource"
}

variable "eks_cluster_name" {
  type        = string
  description = "The EKS cluster name"
}

variable "domain_zone_id" {
  type        = string
  description = "value"
}