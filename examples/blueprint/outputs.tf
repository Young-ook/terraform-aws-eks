output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "codebuild" {
  description = "Bash script to run the build projects using CodeBuild"
  value = {
    amd64 = module.ci.hellojs-amd64.build
    arm64 = module.ci.hellojs-arm64.build
  }
}

output "features" {
  description = "Features configurations of the AWS EKS cluster"
  value       = module.eks.features
}
