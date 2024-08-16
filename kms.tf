resource "aws_kms_key" "encryption_key" {
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

resource "aws_kms_replica_key" "secondary" {
  provider = aws.secondary
  
  description = "Replica of ${aws_kms_key.encryption_key.id}"
  deletion_window_in_days = 7
  primary_key_arn = aws_kms_key.encryption_key.arn
}

output "encryption_key_id" {
  value = aws_kms_key.encryption_key.id
}
