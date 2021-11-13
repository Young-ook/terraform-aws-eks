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

output "features" {
  description = "Features configuration of the AWS EKS and CloudWatch"
  value = zipmap(
    ["eks", "cw"],
    [module.eks.features, module.cw.features]
  )
}
