resource "aws_dynamodb_table" "primary" {
  provider = aws.primary

  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  server_side_encryption = {
    enabled = true
  }

  point_in_time_recovery = {
    enabled = true
  }
  
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_dynamodb_table" "secondary" {
  provider = aws.secondary

  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption = {
    enabled = true
  }

  point_in_time_recovery = {
    enabled = true
  }

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

resource "aws_dynamodb_global_table" "global" {
  provider = aws.primary

  name = var.dynamodb_name

  replica {
    region_name = data.aws_region.primary.name
  }

  replica {
    region_name = data.aws_region.secondary.name
  }
  
  depends_on = [
    aws_dynamodb_table.primary,
    aws_dynamodb_table.secondary,
  ]
}

resource "aws_iam_policy" "global_table" {
  description = "Terraform lock table access policy"
  name = "${var.iam_prefix}LockTableAccess"
  policy = data.aws_iam_policy_document.global_table.json

  tags = var.tags
}
data "aws_iam_policy_document" "global_table" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      aws_dynamodb_global_table.global.arn
    ]
  }
}