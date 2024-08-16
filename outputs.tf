output "primary_bucket_name" {
  value = aws_s3_bucket.primary.id
}
output "secondary_bucket_name" {
  value = aws_s3_bucket.secondary.id
}

output "encryption_key_id" {
  value = aws_kms_key.primary.key_id
}

output "lock_table_name" {
  value = aws_dynamodb_table.primary.name
}