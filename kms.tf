resource "aws_kms_key" "primary" {
  provider = aws.primary
  
  description = "This key is used to encrypt state files"
  deletion_window_in_days = 14
  enable_key_rotation = true
  multi_region = true

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
resource "aws_kms_key_policy" "primary" {
  provider = aws.primary

  key_id = aws_kms_key.primary.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "terraform-encryption-key"
    Statement = [
      {
        Sid    = "Enable Root User"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.primary.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Enable Terraform Role"
        Effect = "Allow"
        Principal = {
          AWS = var.encryption_key_access_allowed_arns
        },
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:ListKeys"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_kms_replica_key" "secondary" {
  provider = aws.secondary
  
  description = "Replica of ${aws_kms_key.primary.id}"
  deletion_window_in_days = 7
  primary_key_arn = aws_kms_key.primary.arn
}
resource "aws_kms_key_policy" "secondary" {
  provider = aws.secondary

  key_id = aws_kms_replica_key.secondary.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "terraform-encryption-key"
    Statement = [
      {
        Sid    = "Enable Root User"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.secondary.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Enable Terraform Role"
        Effect = "Allow"
        Principal = {
          AWS = var.encryption_key_access_allowed_arns
        },
        Action   = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:ListKeys"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "key_access" {
  provider = aws.primary
  
  description = "Terraform kms access policy"
  name = "${var.iam_prefix}KeyAccess"
  policy = data.aws_iam_policy_document.key_access.json

  tags = var.tags
}
data "aws_iam_policy_document" "key_access" {
  provider = aws.primary
  
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:ListKeys"
    ]
    resources = [
      aws_kms_key.primary.arn,
      aws_kms_replica_key.secondary.arn
    ]
  }
}
