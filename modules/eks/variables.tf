# Will be added to all resources "Name" tag
variable "env_name" {
  type        = string
  description = "the default environment name to be added to each resource tag"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags to be added to all resources for auditing or cost management"
}

variable "cluster_name" {
  type = string
}

variable "eks_node_group_name" {
  type        = string
  description = "The name of the node group assigned to the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Cluster version"
}

variable "instance_types" {
  type        = list(string)
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "desired_size" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "max_size" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "min_size" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "eks_vpc_id" {
  type        = string
  description = "Where the EKS will be deployed"
}
variable "eks_control_plane_subnet_ids" {
  type = list(string)
}

variable "eks_worker_node_subnet_ids" {
  type = list(string)
}

variable "authorized_source_ranges" {
  type        = list(string)
  description = "Addresses or CIDR blocks which are allowed to connect to the eks cluster. The default behavior is to allow anyone (0.0.0.0/0) access. You should restrict access to external IPs that need to access the cluster."
  default     = ["0.0.0.0/0"]
}

variable "eks_access_config" {
  type        = string
  description = "How users will access the cluster. the possible options are: API, CONFIG_MAP(legacy), or API_AND_CONFIG_MAP"
  default     = "API"
}

variable "eks_enabled_cluster_log_types" {
  type        = list(string)
  description = "List of the desired control plane logging to enable"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_lbc_version" {
  type        = string
  description = "The version of the AWS Load Balancer Controller to deploy"
  default     = "1.17.0"
}

variable "eks_access_entry_users_list" {
  type        = list(string)
  description = "List of user ARNs to be associated with the EKS access entry."
}

variable "eks_access_entry_policy_arn" {
  type        = string
  description = "The ARN of the access policy to be associated with the EKS access entry."
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}