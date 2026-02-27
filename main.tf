terraform {
  backend "s3" {
    bucket = "vci-terraform-statefiles"
    key    = "test-cluster.tfstate"
    region = "eu-central-1"
    use_lockfile = true
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

module "external-dns" {
  source           = "./modules/external-dns"
  chart_version    = var.external_dns_chart_version
  aws_region       = var.region
  eks_cluster_name = module.eks_test_cluster.eks_cluster_name
  depends_on       = [module.hosted_zone]
}

module "acm_wildcard_certificate" {
  source         = "./modules/acm-certificate"
  fqdn           = var.sub_domain_name
  domain_zone_id = module.hosted_zone.sub_domain_zone_id
  depends_on     = [module.hosted_zone]
}

module "argocd" {
  source             = "./modules/argocd"
  chart_version      = var.argocd_chart_version
  domain_name        = "argocd.${var.sub_domain_name}"
  ingress_class_name = var.argocd_ingress_class_name
  ingress_group_name = var.argocd_ingress_group_name
  avp_version        = var.argocd_avp_version
  ingress_tags       = var.common_tags
  eks_cluster_name   = module.eks_test_cluster.eks_cluster_name
  domain_zone_id     = module.hosted_zone.sub_domain_zone_id
  depends_on         = [module.acm_wildcard_certificate, module.external-dns]
}

data "aws_caller_identity" "current_caller_identity" {

}
# Read local files and create a map of names to policy content
locals {
  # We transform the list from tfvars into a map that includes the actual JSON content
  identities_with_content = [
    for pi in var.pod_identities : {
      name            = pi.name
      namespace       = pi.namespace
      service_account = pi.service_account
      # We read the file here, relative to THIS main.tf
      policy_json = templatefile("${path.root}/${pi.policy_path}", {
        account_id = data.aws_caller_identity.current_caller_identity.account_id
      })
    }
  ]
}

module "pod_identities" {
  source         = "./modules/pod-identity-association"
  cluster_name   = module.eks_test_cluster.eks_cluster_name
  pod_identities = local.identities_with_content
  depends_on     = [module.eks_test_cluster]
}

module "kms_vault_key" {
  source          = "./modules/kms-key"
  key_name        = "vault-key"
  account_id      = data.aws_caller_identity.current_caller_identity.account_id
  key_admins_list = var.eks_access_entry_users_list
  key_role_list   = [module.pod_identities.pod_identity_role_arns["vault"]]
  depends_on      = [module.pod_identities]
}

#### Create hashicorp vault tls, license, and kms key arn as kubernetes secrets to get read by argocd application as env variables ###
# Create the namespace first so the secret has a home
resource "kubernetes_namespace_v1" "vault" {
  metadata {
    name = "vault"
  }
  depends_on = [ module.eks_test_cluster ]
}

# Create the secret containing all your "Bridge" metadata
resource "kubernetes_secret_v1" "vault_infra_metadata" {
  metadata {
    name      = "vault-infra-metadata"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }

  type = "Opaque"

  data = {
    # 1. KMS Key ARN from your KMS module
    KMS_KEY_ID = module.kms_vault_key.key_id

    # 2. Vault License (passed as a variable to TF)
    "vault.hclic" = sensitive(file("${path.root}/tls/vault/vault.hclic"))

    # 3. TLS Certificates (passed as variables or read from files)
    "tls.crt" = sensitive(file("${path.root}/tls/vault/tls.crt"))
    "tls.key" = sensitive(file("${path.root}/tls/vault/tls.key"))
    "ca.crt"  = sensitive(file("${path.root}/tls/vault/ca.crt"))
  }
  depends_on = [ kubernetes_namespace_v1.vault ]
}


resource "kubernetes_manifest" "solar_app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "solar-app-of-apps"
      namespace = "argocd"
      # Add the finalizer here
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/automation-handson/solar-gitops.git"
        targetRevision = "main"
        path           = "argocd/argocd-apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  # Highly Recommended: Ensure ArgoCD is installed before creating the app
  depends_on = [module.argocd, kubernetes_secret_v1.vault_infra_metadata, module.kms_vault_key] 
}