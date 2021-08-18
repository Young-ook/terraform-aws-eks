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
  description = "Features configurations of the AWS EKS cluster"
  value       = module.eks.features
}

output "url" {
  description = "A URL of generated ECR repository"
  value       = module.ecr.url
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this ECR repository. If you want to make an IAM role or instance-profile has permissions to manage this repository, please attach the `poliy_arn` of this output on your side."
  value       = module.ecr.policy_arns
}

resource "local_file" "build" {
  content = templatefile("${path.module}/templates/build.tpl", {
    region  = var.aws_region
    ecr_uri = module.ecr.url
  })
  filename        = "${path.cwd}/docker-build.sh"
  file_permission = "0400"
}

resource "local_file" "manifest" {
  content = templatefile("${path.module}/templates/hello-nodejs.tpl", {
    ecr_uri = module.ecr.url
  })
  filename        = "${path.cwd}/hello-nodejs.yaml"
  file_permission = "0400"
}
