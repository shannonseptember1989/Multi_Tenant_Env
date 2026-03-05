output "pipeline_role_arn"  { value = aws_iam_role.pipeline.arn }
output "pipeline_role_name" { value = aws_iam_role.pipeline.name }
output "pipeline_policy_arn" { value = aws_iam_policy.pipeline.arn }
output "oidc_provider_arn"  { value = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : null }
