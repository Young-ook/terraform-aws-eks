# Amazon EKS with Add-ons

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source  = "Young-ook/sagemaker/aws//modules/vpc"
  version = "> 0.0.6"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

# eks
module "eks" {
  source              = "../../"
  name                = var.name
  tags                = var.tags
  subnets             = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  enable_ssm          = var.enable_ssm
}

module "addons" {
  for_each = {
    for addon in [
      {
        name     = "vpc-cni"
        eks_name = module.eks.cluster.name
      },
      {
        name     = "coredns"
        eks_name = module.eks.cluster.name
      },
      {
        name     = "kube-proxy"
        eks_name = module.eks.cluster.name
      },
      {
        name     = "aws-ebs-csi-driver"
        eks_name = module.eks.cluster.name
      },
    ] : addon.name => addon
  }
  source       = "../../modules/addon"
  tags         = var.tags
  addon_config = each.value
}
