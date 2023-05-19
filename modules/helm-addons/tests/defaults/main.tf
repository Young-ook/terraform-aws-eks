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
    {
      name           = "karpenter"
      chart_name     = "oci://public.ecr.aws/karpenter/karpenter"
      chart_version  = "v0.27.1"
      namespace      = "karpenter"
      serviceaccount = "karpenter"
      values = {
        "settings.aws.clusterName"            = module.eks.cluster.name
        "settings.aws.clusterEndpoint"        = module.eks.cluster.control_plane.endpoint
        "settings.aws.defaultInstanceProfile" = module.eks.instance_profile.node_groups.arn
      }
      oidc        = module.eks.oidc
      policy_arns = [aws_iam_policy.kpt.arn]
    },
  ]
}

resource "aws_iam_policy" "kpt" {
  name        = "karpenter"
  tags       = { test = "helm-addons" }
  description = format("Allow karpenter to manage AWS resources")
  policy      = file("${path.module}/policy.karpenter.json")
}
