terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

provider "kubernetes" {
  alias                  = "aws-auth"
  host                   = module.eks.kubeauth.host
  token                  = module.eks.kubeauth.token
  cluster_ca_certificate = module.eks.kubeauth.ca
}

### vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
}

### eks
module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.0"
  kubernetes_version = "1.24"
  subnets            = slice(values(module.vpc.subnets["public"]), 0, 3)
  managed_node_groups = [
    {
      name          = "default"
      desired_size  = 1
      instance_type = "t3.medium"
    },
  ]
}

module "main" {
  depends_on = [module.eks]
  providers  = { kubernetes = kubernetes.aws-auth }
  source     = "../../"
}
