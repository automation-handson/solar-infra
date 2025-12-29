resource "aws_iam_policy" "external_dns_policy" {
  name        = "external_dns_policy"
  description = "IAM policy for External DNS to manage Route53 records"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GlobalRoute53Actions",
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ScopedRoute53Actions",
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "external_dns_role" {
  name = "external_dns_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

resource "aws_eks_pod_identity_association" "external_dns_pod_identity_association" {
  cluster_name    = var.eks_cluster_name
  namespace       = "external-dns"
  service_account = "external-dns-sa"
  role_arn        = aws_iam_role.external_dns_role.arn
  depends_on      = [aws_iam_role_policy_attachment.external_dns_policy_attachment]
}




resource "helm_release" "external-dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true
  version          = var.chart_version

  # Option A: Simple file read (if no variables are needed inside the YAML)
  # values = [
  #   file("${path.module}/external-dns-values.tftpl")
  # ]

  # Option B: templatefile (if you want to pass TF variables into the YAML)
  values = [
    templatefile("${path.module}/external-dns-values.tftpl", {
      aws_region = var.aws_region
    })
  ]
  depends_on = [aws_eks_pod_identity_association.external_dns_pod_identity_association]
}