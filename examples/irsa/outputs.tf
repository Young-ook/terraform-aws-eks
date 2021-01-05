output "eks" {
  description = "The generated AWS EKS cluster"
  value       = module.eks.cluster
}

output "role" {
  description = "The generated role of the EKS node group"
  value       = module.eks.role
}

output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "kubecli" {
  description = "The kubectl command to attach annotations of IAM role for service account"
  value       = module.irsa.kubecli
}

output "features" {
  description = "Features configurations of the AWS EKS cluster"
  value       = module.eks.features
}
