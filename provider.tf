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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75"
    }
  }
}