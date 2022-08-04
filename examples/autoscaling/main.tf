# Autoscaling example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source = "Young-ook/vpc/aws"
  name   = var.name
  tags   = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  subnets             = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
  fargate_profiles    = var.fargate_profiles
  enable_ssm          = var.enable_ssm
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "alb-ingress" {
  source       = "Young-ook/eks/aws//modules/alb-ingress"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}

module "cluster-autoscaler" {
  for_each     = toset(module.eks.features.managed_node_groups_enabled || module.eks.features.node_groups_enabled ? ["enabled"] : [])
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
  features = {
    enable_metrics = true
    enable_logs    = true
  }
}

module "metrics-server" {
  for_each = toset(module.eks.features.managed_node_groups_enabled || module.eks.features.node_groups_enabled ? ["enabled"] : [])
  source   = "Young-ook/eks/aws//modules/metrics-server"
  oidc     = module.eks.oidc
  tags     = { env = "test" }
}

module "prometheus" {
  for_each     = toset(module.eks.features.managed_node_groups_enabled || module.eks.features.node_groups_enabled ? ["enabled"] : [])
  source       = "../../modules/prometheus"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
  helm = {
    vars = {
      "alertmanager.persistentVolume.storageClass" = "gp2"
      "server.persistentVolume.storageClass"       = "gp2"
    }
  }
}
