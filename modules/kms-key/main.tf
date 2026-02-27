data "aws_iam_policy_document" "kms_policy" {
  # 1. ROOT ACCESS: Allows IAM policies to control the key
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # 2. ADMIN ACCESS: Full management rights
  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.key_admins_list
    }
    actions = [
      "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*",
      "kms:Put*", "kms:Update*", "kms:Revoke*", "kms:Disable*",
      "kms:Get*", "kms:Delete*", "kms:TagResource", "kms:UntagResource",
      "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  # 3. CONSUMER ACCESS: Cryptographic operations only
  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.key_role_list
    }
    actions = [
      "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
      "kms:GenerateDataKey*", "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "this" {
  description             = "KMS Key for ${var.key_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_policy.json
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.key_name}"
  target_key_id = aws_kms_key.this.key_id
}