# output variables 

output "name" {
  value       = local.name
  description = "The EKS cluster name"
}

output "features" {
  value = {
    "app_mesh_enabled"           = local.app_mesh_enabled
    "container_insights_enabled" = local.container_insights_enabled
    "node_groups_enabled"        = local.node_groups_enabled
  }
  description = "Features configurations for the EKS "
}

output "cluster" {
  value       = aws_eks_cluster.cp
  description = "The EKS cluster attributes"
}

output "role" {
  value = (local.node_groups_enabled ? zipmap(
    ["name", "arn"],
    [aws_iam_role.ng.0.name, aws_iam_role.ng.0.arn]
  ) : null)
  description = "The generated role of the EKS node group"
}

output "oidc" {
  value = zipmap(
    ["url", "arn"],
    [local.oidc["url"], local.oidc["arn"]]
  )
  description = "The OIDC provider attributes for IAM Role for ServiceAccount"
}

output "tags" {
  value = {
    "shared"       = local.eks-shared-tag
    "owned"        = local.eks-owned-tag
    "elb"          = local.eks-elb-tag
    "internal-elb" = local.eks-internal-elb-tag
  }
  description = "The generated tags for EKS integration"
}

data "aws_region" "current" {}

output "kubeconfig" {
  value = join(" ", [
    "bash -e",
    format("%s/script/update-kubeconfig.sh", path.module),
    format("-r %s", data.aws_region.current.name),
    format("-n %s", aws_eks_cluster.cp.name),
    "-k kubeconfig",
  ])
  description = "Bash script to update kubeconfig file"
}
