region         = "eu-central-1"
az = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
common_tags = {
  Environment     = "SANDBOX"
  Project         = "vf-grp-ias-dev-ias-sanbox"
  ManagedBy       = "vcisecretmanagement@vodafone.com"
  SecurityZone    = "DEV"
  Confidentiality = "C2"
  TaggingVersion  = "V2.4"
}
env_name       = "test-eks-cluster"
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
# subnets = {
#   subnet-private-1 = {
#     cidr_block        = "10.0.0.0/23"
#     availability_zone = "eu-central-1a"
#   }
#   subnet-private-2 = {
#     cidr_block        = "10.0.2.0/23"
#     availability_zone = "eu-central-1b"
#   }
#   subnet-private-3 = {
#     cidr_block        = "10.0.4.0/23"
#     availability_zone = "eu-central-1c"
#   }
# }
cluster_version = "1.34"
instance_types  = ["t3.xlarge"]
desired_size    = "3"
max_size        = "3"
min_size        = "3"