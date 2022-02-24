output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "kfinstall" {
  description = "Bash script to install kubeflow to the EKS cluster"
  value       = "bash kfinst.sh"
}

output "kfuninstall" {
  description = "Bash script to uninstall kubeflow from the EKS cluster"
  value       = "bash kfuninst.sh"
}

output "features" {
  description = "Features configurations of the AWS EKS cluster"
  value       = module.eks.features
}
