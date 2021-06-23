# output variables 

output "cluster" {
  description = "The EKS cluster attributes"
  value = {
    name          = aws_eks_cluster.cp.name
    control_plane = aws_eks_cluster.cp
    data_plane = {
      node_groups         = local.node_groups_enabled ? aws_autoscaling_group.ng : null
      managed_node_groups = local.managed_node_groups_enabled ? aws_eks_node_group.ng : null
      fargate             = local.fargate_enabled ? aws_eks_fargate_profile.fargate : null
    }
  }
}

output "role" {
  description = "The generated role of the EKS node group"
  value = (local.node_groups_enabled || local.managed_node_groups_enabled ? zipmap(
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

data "aws_eks_cluster_auth" "cp" {
  name = aws_eks_cluster.cp.name
}

output "helmconfig" {
  description = "The configurations map for Helm provider"
  sensitive   = true
  value = {
    host  = aws_eks_cluster.cp.endpoint
    token = data.aws_eks_cluster_auth.cp.token
    ca    = aws_eks_cluster.cp.certificate_authority.0.data
  }
}

output "features" {
  description = "Features configurations for the EKS"
  value = {
    "managed_node_groups_enabled" = local.managed_node_groups_enabled
    "node_groups_enabled"         = local.node_groups_enabled
    "fargate_enabled"             = local.fargate_enabled
    "ssm_enabled"                 = var.enable_ssm
  }
}
