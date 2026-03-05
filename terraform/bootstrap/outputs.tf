output "state_bucket_name" {
  description = "S3 bucket name — set as tf_state_bucket in ansible/environments/*/vars.yml"
  value       = aws_s3_bucket.terraform_state.id
}

output "lock_table_name" {
  description = "DynamoDB table name — set as tf_lock_table in ansible/environments/*/vars.yml"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "state_bucket_arn" {
  description = "S3 bucket ARN — referenced in the IAM pipeline policy"
  value       = aws_s3_bucket.terraform_state.arn
}
