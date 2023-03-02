terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
}

module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.0"
  tags               = { test = "helm-addons" }
  subnets            = slice(values(module.vpc.subnets["public"]), 0, 3)
  enable_ssm         = true
  kubernetes_version = "1.24"
  node_groups = [
    {
      name          = "default"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      instance_type = "t3.xlarge"
    },
  ]
}

module "main" {
  depends_on = [module.eks]
  source     = "../.."
  tags       = { test = "helm-addons" }
  addons = [
    {
      repository     = "https://kubernetes-sigs.github.io/metrics-server/"
      name           = "metrics-server"
      chart_name     = "metrics-server"
      namespace      = "kube-system"
      serviceaccount = "metrics-server"
      values = {
        "args[0]" = "--kubelet-preferred-address-types=InternalIP"
      }
    },
  ]
}
