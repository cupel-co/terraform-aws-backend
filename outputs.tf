output "primary_bucket_name" {
  value = aws_s3_bucket.primary.id
}
output "secondary_bucket_name" {
  value = aws_s3_bucket.secondary.id
}
output "buckets_access_policy_arn" {
  value = aws_iam_policy.buckets_access.arn
}

output "encryption_key_id" {
  value = aws_kms_key.primary.key_id
}
output "encryption_key_access_policy_arn" {
  value = aws_iam_policy.key_access.arn
}

output "lock_table_name" {
  value = aws_dynamodb_table.lock_table.name
}
output "lock_table_access_policy_arn" {
  value = aws_iam_policy.lock_table.arn
}
