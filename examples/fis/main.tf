# AWS Fault Injection Simulator

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### foundation/network
module "vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name                = var.name
  tags                = var.tags
  azs                 = var.azs
  cidr                = var.cidr
  enable_igw          = true
  enable_ngw          = true
  single_ngw          = true
  vpc_endpoint_config = []
}

### application/eks
module "eks" {
  source             = "Young-ook/eks/aws"
  name               = var.name
  tags               = var.tags
  subnets            = values(module.vpc.subnets["private"])
  kubernetes_version = var.kubernetes_version
  enable_ssm         = true
  fargate_profiles = [
    {
      name      = "loadtest"
      namespace = "loadtest"
    },
  ]
  managed_node_groups = [
    {
      name          = "sockshop"
      desired_size  = 3
      min_size      = 3
      max_size      = 9
      instance_type = "t3.small"
    }
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "container-insights" {
  source       = "Young-ook/eks/aws//modules/container-insights"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
}

module "cluster-autoscaler" {
  source       = "Young-ook/eks/aws//modules/cluster-autoscaler"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
}

module "metrics-server" {
  source       = "Young-ook/eks/aws//modules/metrics-server"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
}
