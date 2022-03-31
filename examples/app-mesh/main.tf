# App Mesh example

terraform {
  required_version = "~> 1.0"
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
  enable_ssm          = var.enable_ssm
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess",
  ]
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
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = { env = "test" }
  helm = {
    version = "1.2.0"
  }
}
