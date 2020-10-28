# Complete example

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
}

data "aws_partition" "current" {}

module "irsa" {
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  name           = join("-", ["irsa", var.name, "xray-write"])
  namespace      = "default"
  serviceaccount = "app-mesh-xray-write"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns = [
    format("arn:%s:iam::aws:policy/AWSXRayDaemonWriteAccess", data.aws_partition.current.partition),
  ]
  tags = var.tags
}

# utility
provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
    load_config_file       = false
  }
}

module "alb-ingress" {
  source       = "Young-ook/eks/aws//modules/alb-ingress"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}

module "app-mesh" {
  source       = "Young-ook/eks/aws//modules/app-mesh"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}

module "cluster-autoscaler" {
  source       = "Young-ook/eks/aws//modules/cluster-autoscaler"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}

module "container-insights" {
  source       = "Young-ook/eks/aws//modules/container-insights"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
