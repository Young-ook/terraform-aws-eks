# Amazon EKS with Add-ons

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### eks
module "eks" {
  source              = "../../"
  name                = var.name
  tags                = var.tags
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
