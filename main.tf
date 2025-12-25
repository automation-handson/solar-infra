terraform {
  backend "s3" {
    bucket = "vci-terraform-statefiles"
    key    = "test-cluster.tfstate"
    region = "eu-central-1"
  }
}

module "networking" {
  source                 = "./modules/networking"
  az                     = var.az
  common_tags            = var.common_tags
  env_name               = var.env_name
  vpc_cidr_block         = var.vpc_cidr_block
  private_network_config = var.private_network_config
  public_network_config  = var.public_network_config
  ingress_nacl_rules     = var.ingress_nacl_rules
  egress_nacl_rules      = var.egress_nacl_rules
}

module "eks_test_cluster" {
  source                        = "./modules/eks"
  env_name                      = var.env_name
  region                        = var.region
  common_tags                   = var.common_tags
  cluster_name                  = var.eks_cluster_name
  eks_node_group_name           = var.eks_node_group_name
  cluster_version               = var.eks_cluster_version
  instance_types                = var.eks_instance_types
  desired_size                  = var.eks_desired_size
  max_size                      = var.eks_max_size
  min_size                      = var.eks_min_size
  eks_vpc_id                    = module.networking.vpc_id
  eks_control_plane_subnet_ids  = module.networking.private_subnet_ids
  eks_worker_node_subnet_ids    = module.networking.private_subnet_ids
  authorized_source_ranges      = var.eks_authorized_source_ranges
  eks_access_config             = var.eks_access_config
  eks_enabled_cluster_log_types = var.eks_enabled_cluster_log_types
  eks_access_entry_users_list   = var.eks_access_entry_users_list
  eks_access_entry_policy_arn   = var.eks_access_entry_policy_arn
  eks_lbc_version               = var.eks_lbc_version
  depends_on                    = [module.networking]
}

module "hosted_zone" {
  source           = "./modules/hosted-zone"
  root_domain_name = var.root_domain_name
  sub_domain_name  = var.sub_domain_name
  depends_on       = [module.eks_test_cluster]
}

module "acm_wildcard_certificate" {
  source     = "./modules/acm-certificate"
  fqdn       = var.sub_domain_name
  domain_zone_id = module.hosted_zone.sub_domain_zone_id
  depends_on = [module.hosted_zone]
}