# Complete example

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# vpc
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.63.0"
  name               = var.name
  azs                = var.azs
  cidr               = "10.0.0.0/16"
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = module.eks.tags.shared
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  subnets             = module.vpc.private_subnets
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
  fargate_profiles    = var.fargate_profiles
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

module "metrics-server" {
  source       = "Young-ook/eks/aws//modules/metrics-server"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
