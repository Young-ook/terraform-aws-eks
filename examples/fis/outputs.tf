output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value       = module.eks.kubeconfig
}
