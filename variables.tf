variable "region" {
  description = "An optional description of this resource (triggers recreation on change)."
  type        = string
}

variable "az" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "common_tags" {
  description = "Tags to be added to all resources for auditing or cost management"
  type        = map(string)
}

variable "env_name" {
  description = "the default environment name to be added to each resource tag"
  type        = string
}

variable "vpc_cidr_block" {
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

# variable "subnets" {
#   description = "Apigee Environment Groups."
#   type = map(object({
#     cidr_block        = string
#     availability_zone = string
#   }))
#   default = {}
# }

variable "ingress_nacl_rules" {
  description = "Map of ingress NACL rules"
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
}

variable "egress_nacl_rules" {
  description = "Map of egress NACL rules"
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
}

variable "cluster_version" {
  type        = string
  description = "Cluster version"
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
