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
  source  = "Young-ook/eks/aws"
  version = "2.0.3"
  subnets = values(module.vpc.subnets["public"])
}

module "main" {
  for_each = toset(["null", "karpenter"])
  source         = "../.."
  name           = each.key == "null" ? null : each.key
  namespace      = "default"
  serviceaccount = "mysa"
  oidc_url       = module.eks.oidc["url"]
  oidc_arn       = module.eks.oidc["arn"]
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(regex("^irsa", module.main["null"].name))
  }
}
