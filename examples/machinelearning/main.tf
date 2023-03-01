### Machine Learning with Kubeflow

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  name    = var.name
  tags    = var.tags
  vpc_config = {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

### eks
module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.3"
  name               = var.name
  tags               = var.tags
  subnets            = slice(values(module.vpc.subnets["private"]), 0, 3)
  enable_ssm         = true
  kubernetes_version = var.kubernetes_version
  managed_node_groups = [
    {
      name          = "kubeflow"
      min_size      = 1
      max_size      = 9
      desired_size  = 4
      instance_type = "t3.large"
    }
  ]
}

### helm-addons
provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

module "kubeflow" {
  depends_on         = [module.eks]
  source             = "./modules/kubeflow"
  tags               = var.tags
  kubeflow_helm_repo = var.kubeflow_helm_repo
}
