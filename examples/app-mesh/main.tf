# App Mesh example

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region = var.aws_region
}

# build container image
module "codebuild" {
  source = "./modules/codebuild"
  name   = var.name
  tags   = var.tags
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
  policy_arns         = ["arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"]
}

# utilities
provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "app-mesh" {
  source       = "Young-ook/eks/aws//modules/app-mesh"
  enabled      = true
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
  helm = {
    version = "1.2.0"
  }
}
