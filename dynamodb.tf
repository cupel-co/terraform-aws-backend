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

resource "aws_dynamodb_global_table" "table" {
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
