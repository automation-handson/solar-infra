provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment     = "SANDBOX"
      Project         = "vf-grp-ias-dev-ias-sanbox"
      ManagedBy       = "vcisecretmanagement@vodafone.com"
      SecurityZone    = "DEV"
      Confidentiality = "C2"
      TaggingVersion  = "V2.4"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks_test_cluster.eks_host
    cluster_ca_certificate = base64decode(module.eks_test_cluster.eks_certificate_authority)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_test_cluster.eks_cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks_test_cluster.eks_host
  cluster_ca_certificate = base64decode(module.eks_test_cluster.eks_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_test_cluster.eks_cluster_name]
    command     = "aws"
  }
}

provider "http" {

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }
  }
}