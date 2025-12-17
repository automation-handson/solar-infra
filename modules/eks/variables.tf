variable "region" {
  type = string
}

variable "az" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "vpc_cidr_block" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
}

variable "env_name" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
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

variable "cluster_version" {
  type        = string
  description = "Cluster version"
}

variable "authorized_source_ranges" {
  type        = string
  description = "Addresses or CIDR blocks which are allowed to connect to the Vault IP address. The default behavior is to allow anyone (0.0.0.0/0) access. You should restrict access to external IPs that need to access the Vault cluster."
  default     = "0.0.0.0/0"
}


variable "node_group_name" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
}

variable "instance_types" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = list(string)
}

variable "desired_size" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
}

variable "max_size" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
}

variable "min_size" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
}

variable "common_tags" {
  description = "Tags to be added to all resources for auditing or cost management"
  type = map(string)
}