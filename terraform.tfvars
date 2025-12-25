region   = "eu-central-1"
az       = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
env_name = "sandbox"
common_tags = {
  Environment     = "SANDBOX"
  Project         = "vf-grp-ias-dev-ias-sanbox"
  ManagedBy       = "vcisecretmanagement@vodafone.com"
  SecurityZone    = "DEV"
  Confidentiality = "C2"
  TaggingVersion  = "V2.4"
}
vpc_cidr_block = "10.0.0.0/16"

private_network_config = {
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

public_network_config = {
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

ingress_nacl_rules = {
  "99"  = { rule_number = 99, protocol = "tcp", from_port = 1025, to_port = 65535, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  "100" = { rule_number = 100, protocol = "-1", from_port = 0, to_port = 0, cidr_block = "10.0.0.0/16", rule_action = "allow" }
  "101" = { rule_number = 101, protocol = "tcp", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  "102" = { rule_number = 102, protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  "105" = { rule_number = 105, protocol = "tcp", from_port = 8080, to_port = 8080, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  "106" = { rule_number = 106, protocol = "tcp", from_port = 8443, to_port = 8443, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  "107" = { rule_number = 107, protocol = "tcp", from_port = 389, to_port = 389, cidr_block = "0.0.0.0/0", rule_action = "allow" }
  "108" = { rule_number = 108, protocol = "tcp", from_port = 22, to_port = 22, cidr_block = "41.44.149.201/32", rule_action = "allow" }
}

egress_nacl_rules = {
  "100" = { rule_number = 100, protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0", rule_action = "allow" }
}

eks_cluster_name              = "sms-cluster"
eks_node_group_name           = "NG"
eks_cluster_version           = "1.34"
eks_instance_types            = ["t3.xlarge"]
eks_desired_size              = "3"
eks_max_size                  = "3"
eks_min_size                  = "3"
eks_authorized_source_ranges  = ["0.0.0.0/0"]
eks_access_config             = "API"
eks_enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

eks_lbc_version = "1.17.0"

eks_access_entry_users_list = ["arn:aws:iam::221133053333:user/anas.hassan1@vodafone.com"]
eks_access_entry_policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

root_domain_name = "devvf.com"
sub_domain_name  = "sandbox.devvf.com"