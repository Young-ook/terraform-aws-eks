### output variables

output "spinnaker_role_arn" {
  description = "An IAM Role ARN of the Spinnaker"
  value       = module.devops.addons.irsa["spinnaker"].arn
}
