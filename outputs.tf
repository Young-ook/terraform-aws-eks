# output variables 

output "name" {
  description = "The EKS cluster name"
  value       = local.name
}

output "cluster" {
  description = "The EKS cluster attributes"
  value       = aws_eks_cluster.cp
}

output "role" {
  description = "The generated role of the EKS node group"
  value = (local.node_groups_enabled ? zipmap(
    ["name", "arn"],
    [aws_iam_role.ng.0.name, aws_iam_role.ng.0.arn]
  ) : null)
}

output "oidc" {
  description = "The OIDC provider attributes for IAM Role for ServiceAccount"
  value = zipmap(
    ["url", "arn"],
    [local.oidc["url"], local.oidc["arn"]]
  )
}

output "tags" {
  description = "The generated tags for EKS integration"
  value = {
    "shared"       = local.eks-shared-tag
    "owned"        = local.eks-owned-tag
    "elb"          = local.eks-elb-tag
    "internal-elb" = local.eks-internal-elb-tag
  }
}

data "aws_region" "current" {}

output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value = join(" ", [
    "bash -e",
    format("%s/script/update-kubeconfig.sh", path.module),
    format("-r %s", data.aws_region.current.name),
    format("-n %s", aws_eks_cluster.cp.name),
    "-k kubeconfig",
  ])
}

output "features" {
  description = "Features configurations for the EKS "
  value = {
    "app_mesh_enabled"            = local.app_mesh_enabled
    "container_insights_enabled"  = local.container_insights_enabled
    "managed_node_groups_enabled" = local.managed_node_groups_enabled
    "node_groups_enabled"         = local.node_groups_enabled
  }
}
