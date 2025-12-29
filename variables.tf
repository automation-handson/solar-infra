# General Variables
variable "region" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "az" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

# Will be added to all resources "Name" tag
variable "env_name" {
  type        = string
  description = "the default environment name to be added to each resource tag"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags to be added to all resources for auditing or cost management"
}

# VPC and Networking Variables
variable "vpc_cidr_block" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "private_network_config" {
  type = map(object({
    cidr_block               = string
    associated_public_subnet = string
  }))

  default = {
    "private-security-1" = {
      cidr_block               = "10.0.0.0/23"
      associated_public_subnet = "public-security-1"
    },
    "private-security-2" = {
      cidr_block               = "10.0.2.0/23"
      associated_public_subnet = "public-security-2"
    },
    "private-security-3" = {
      cidr_block               = "10.0.4.0/23"
      associated_public_subnet = "public-security-3"
    }
  }
}

variable "public_network_config" {
  type = map(object({
    cidr_block = string
  }))

  default = {
    "public-security-1" = {
      cidr_block = "10.0.8.0/23"
    },
    "public-security-2" = {
      cidr_block = "10.0.10.0/23"
    },
    "public-security-3" = {
      cidr_block = "10.0.12.0/23"
    }
  }
}

variable "ingress_nacl_rules" {
  type = map(object({
    rule_number = number
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_block  = string
    rule_action = string
  }))
  default = {
    "99"  = { rule_number = 99, protocol = "tcp", from_port = 1025, to_port = 65535, cidr_block = "0.0.0.0/0", rule_action = "allow" }
    "100" = { rule_number = 100, protocol = "-1", from_port = 0, to_port = 0, cidr_block = "10.0.0.0/16", rule_action = "allow" }
    "101" = { rule_number = 101, protocol = "tcp", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0", rule_action = "allow" }
    "102" = { rule_number = 102, protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0", rule_action = "allow" }
    "105" = { rule_number = 105, protocol = "tcp", from_port = 8080, to_port = 8080, cidr_block = "0.0.0.0/0", rule_action = "allow" }
    "106" = { rule_number = 106, protocol = "tcp", from_port = 8443, to_port = 8443, cidr_block = "0.0.0.0/0", rule_action = "allow" }
    "107" = { rule_number = 107, protocol = "tcp", from_port = 389, to_port = 389, cidr_block = "0.0.0.0/0", rule_action = "allow" }
    "108" = { rule_number = 108, protocol = "tcp", from_port = 22, to_port = 22, cidr_block = "41.44.149.201/32", rule_action = "allow" }
  }
  description = "Map of ingress NACL rules"
}

variable "egress_nacl_rules" {
  type = map(object({
    rule_number = number
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_block  = string
    rule_action = string
  }))
  default = {
    "100" = { rule_number = 100, protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  }
  description = "Map of egress NACL rules"
}

# EKS Variables
variable "eks_cluster_name" {
  type = string
}

variable "eks_node_group_name" {
  type        = string
  description = "The name of the node group assigned to the EKS cluster"
}

variable "eks_cluster_version" {
  type        = string
  description = "Cluster version"
}

variable "eks_instance_types" {
  type        = list(string)
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "eks_desired_size" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "eks_max_size" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "eks_min_size" {
  type        = string
  description = "An optional description of this resource (triggers recreation on change)."
}

variable "eks_authorized_source_ranges" {
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

variable "root_domain_name" {
  type        = string
  default     = null
  description = "If specified, tf will create a root hosted zone. if not, tf will skip the root domain and create a subdomain"
}

variable "sub_domain_name" {
  type        = string
  description = "The subdomain name to create the hosted zone for, e.g., dev.example.com"
}

variable "argocd_chart_version" {
  type        = string
  description = "Argocd Chart Version"
  default     = "7.7.0"
}

variable "argocd_ingress_class_name" {
  type        = string
  description = "The Ingress class name that will be used by argocd for the ingress resource"
}

variable "argocd_ingress_group_name" {
  type        = string
  description = "The Ingress group name that will be used by argocd for the ingress resource"
}

variable "argocd_avp_version" {
  type        = string
  description = "Argocd vault plugin version"
  default     = "1.18.0"
}

variable "external_dns_chart_version" {
  type        = string
  description = "external-dns helm chart version"
  default     = "1.19.0"
}