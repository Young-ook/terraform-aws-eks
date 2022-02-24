output "vpc" {
  description = "The attributes of Amazon VPC"
  value       = module.vpc.vpc
}

output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value       = module.eks.kubeconfig
}

output "addons" {
  description = "EKS addons"
  value       = module.addons
}
