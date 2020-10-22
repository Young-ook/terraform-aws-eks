provider "helm" {
  alias = "aws-controller"
  kubernetes {
    host                   = aws_eks_cluster.cp.endpoint
    token                  = data.aws_eks_cluster_auth.cp.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.cp.certificate_authority.0.data)
    load_config_file       = false
  }
}

module "alb-ingress" {
  source       = "./modules/alb-ingress"
  depends_on   = [kubernetes_config_map.aws-auth]
  providers    = { helm = helm.aws-controller }
  enabled      = local.node_groups_enabled
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}

module "app-mesh" {
  source       = "./modules/app-mesh"
  depends_on   = [kubernetes_config_map.aws-auth]
  providers    = { helm = helm.aws-controller }
  enabled      = local.app_mesh_enabled
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}

module "cluster-autoscaler" {
  source       = "./modules/cluster-autoscaler"
  depends_on   = [kubernetes_config_map.aws-auth]
  providers    = { helm = helm.aws-controller }
  enabled      = local.node_groups_enabled
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}

module "container-insights" {
  source       = "./modules/container-insights"
  depends_on   = [kubernetes_config_map.aws-auth]
  providers    = { helm = helm.aws-controller }
  enabled      = local.container_insights_enabled
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}
