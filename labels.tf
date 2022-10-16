### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.5"
  name    = var.name == null || var.name == "" ? "eks" : var.name
  petname = var.name == null || var.name == "" ? true : false
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}

## kubernetes tags
locals {
  eks-shared-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "shared"
  }
  eks-owned-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "owned"
  }
  eks-elb-tag = {
    "kubernetes.io/role/elb" = "1"
  }
  eks-internal-elb-tag = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  eks-autoscaler-tag = {
    "k8s.io/cluster-autoscaler/enabled"                = "true"
    format("k8s.io/cluster-autoscaler/%s", local.name) = "owned"
  }
  eks-tag = merge(
    {
      "eks:cluster-name" = local.name
    },
    local.eks-owned-tag,
    local.eks-autoscaler-tag,
  )
}
