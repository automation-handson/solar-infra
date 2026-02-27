# 1. Create the IAM Roles
resource "aws_iam_role" "this" {
  for_each = { for pi in var.pod_identities : pi.name => pi }

  name = "${var.cluster_name}-${each.value.name}-pod-identity"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}

# 2. Create and Attach the Policies
resource "aws_iam_policy" "this" {
  for_each = { for pi in var.pod_identities : pi.name => pi }

  name   = "${var.cluster_name}-${each.value.name}-policy"
  policy = each.value.policy_json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for pi in var.pod_identities : pi.name => pi }

  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

# 3. Create the Pod Identity Association
resource "aws_eks_pod_identity_association" "this" {
  for_each = { for pi in var.pod_identities : pi.name => pi }

  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.this[each.key].arn
}