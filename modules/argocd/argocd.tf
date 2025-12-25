resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.chart_version

  # Option A: Simple file read (if no variables are needed inside the YAML)
  # values = [
  #   file("${path.module}/argocd-values.tftpl")
  # ]

  # Option B: templatefile (if you want to pass TF variables into the YAML)
  values = [
    templatefile("${path.module}/argocd-values.tftpl", {
      domain_name         = var.domain_name,
      acm_certificate_arn = var.acm_certificate_arn,
      ingress_class_name  = var.ingress_class_name,
      ingress_group_name  = var.ingress_group_name,
      avp_version         = var.avp_version,
      ingress_tags        = join(",", [for key, value in var.ingress_tags : "${key}=${value}"])
    })
  ]
}


# 2. Look up the ALB created by the Ingress Controller
data "aws_lb" "ingress_alb" {
  tags = {
    "elbv2.k8s.aws/cluster" = var.eks_cluster_name
    "ingress.k8s.aws/stack" = var.ingress_group_name
  }
}


# 3. Create the Alias Record in Route 53
resource "aws_route53_record" "alb_domain_route53_association" {
  zone_id = var.domain_zone_id # Use the ID from your Subdomain module
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress_alb.dns_name
    zone_id                = data.aws_lb.ingress_alb.zone_id
    evaluate_target_health = true
  }
}