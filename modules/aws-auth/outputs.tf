### output variables

output "configmap" {
  description = "Modified aws-auth configmap data"
  value       = local.merged_aws_auth
}
