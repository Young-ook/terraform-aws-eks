output "eks" {
  value       = module.eks.cluster
  description = "The generated AWS EKS cluster"
}

output "kubeconfig" {
  value       = module.eks.kubeconfig
  description = "Bash script to update the kubeconfig file for the EKS cluster"
}

output "kubecli" {
  value       = module.irsa.kubecli
  description = "The kubectl command to attach annotations of IAM role for service account"
}

output "features" {
  value       = module.eks.features
  description = "Features configurations of the AWS EKS cluster"
}
