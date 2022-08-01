# Amazon EKS with AWS LoadBalancers

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  version             = "2.3.1"
  name                = var.name
  tags                = merge(var.tags, module.eks.tags.shared)
  azs                 = var.azs
  cidr                = var.cidr
  enable_igw          = var.enable_igw
  enable_ngw          = var.enable_ngw
  single_ngw          = var.single_ngw
  vpc_endpoint_config = []
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  version             = "1.7.5"
  name                = var.name
  tags                = var.tags
  subnets             = values(module.vpc.subnets["private"])
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
  fargate_profiles    = var.fargate_profiles
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "lb-controller" {
  source       = "../../modules/lb-controller"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = var.tags
  helm = {
    vars = module.eks.features.fargate_enabled ? {
      vpcId       = module.vpc.vpc.id
      clusterName = module.eks.cluster.name
      } : {
      clusterName = module.eks.cluster.name
    }
  }
}
