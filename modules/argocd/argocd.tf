resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.0"

  # Option A: Simple file read (if no variables are needed inside the YAML)
  values = [
    file("${path.module}/argo-values.yaml")
  ]

  # Option B: templatefile (if you want to pass TF variables into the YAML)
  # values = [
  #   templatefile("${path.module}/argo-values.yaml", {
  #     cluster_name = module.eks.cluster_name
  #   })
  # ]

  depends_on = [
    module.eks.eks_managed_node_groups,
    helm_release.lbc # Important if your values.yaml creates an ALB Ingress
  ]
}