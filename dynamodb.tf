resource "aws_dynamodb_table" "lock_table" {
  provider = aws.primary

  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = true
  
  replica {
    region_name = data.aws_region.secondary.name
    point_in_time_recovery = true
    propagate_tags = true
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

resource "aws_iam_policy" "lock_table" {
  provider = aws.primary
  
  description = "Terraform lock table access policy"
  name = "${var.iam_prefix}LockTableAccess"
  policy = data.aws_iam_policy_document.lock_table.json

  tags = var.tags
}
data "aws_iam_policy_document" "lock_table" {
  provider = aws.primary
  
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      aws_dynamodb_table.lock_table.arn,
      one(aws_dynamodb_table.lock_table.replica.*.arn)
    ]
  }
}