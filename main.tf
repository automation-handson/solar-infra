terraform {
  backend "s3" {
    bucket = "vci-terraform-statefiles"
    key    = "test-cluster.tfstate"
    region = "eu-central-1"
  }
}

module "networking" {
  source                 = "./modules/networking"
  region                 = var.region
  az                     = var.az
  common_tags            = var.common_tags
  env_name               = var.env_name
  vpc_cidr_block         = var.vpc_cidr_block
  private_network_config = var.private_network_config
  public_network_config  = var.public_network_config
  ingress_nacl_rules     = var.ingress_nacl_rules
  egress_nacl_rules      = var.egress_nacl_rules
}