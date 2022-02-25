output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "features" {
  description = "Features configurations of the AWS EKS cluster"
  value       = module.eks.features
}
