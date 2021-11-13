# CloudWatch ContainerInsights example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  enable_ssm          = var.enable_ssm
}

# utilities
provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "cw" {
  source       = "../../modules/container-insights"
  features     = var.enable_cw
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
}
