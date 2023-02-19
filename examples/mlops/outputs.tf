output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "kubeflow" {
  description = "Bash script to manage kubeflow"
  value = {
    kfinst   = "bash kfinst.sh"
    kfuninst = "bash kfuninst.sh"
  }
}
