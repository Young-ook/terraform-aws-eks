# Spot Instances for node groups example

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
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "metrics-server" {
  source = "Young-ook/eks/aws//modules/metrics-server"
  oidc   = module.eks.oidc
  tags   = { env = "test" }
}

module "cluster-autoscaler" {
  source = "Young-ook/eks/aws//modules/cluster-autoscaler"
  oidc   = module.eks.oidc
  tags   = { env = "test" }
  helm = {
    vars = {
      "autoDiscovery.clusterName" = module.eks.cluster.name
    }
  }
}

module "node-termination-handler" {
  source = "Young-ook/eks/aws//modules/node-termination-handler"
  oidc   = module.eks.oidc
  tags   = { env = "test" }
}
