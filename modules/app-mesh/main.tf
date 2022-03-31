## kubernetes aws-app-mesh-controller

# aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  namespace      = lookup(var.helm, "namespace", "appmesh-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-appmesh-controller")
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns = [
    format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", module.aws.partition.partition),
    format("arn:%s:iam::aws:policy/AWSAppMeshFullAccess", module.aws.partition.partition),
  ]
  tags = var.tags
}

resource "helm_release" "appmesh" {
  name             = lookup(var.helm, "name", "appmesh-controller")
  chart            = lookup(var.helm, "chart", "appmesh-controller")
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({
      "region"                                                    = module.aws.region.name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa.arn
      "tracing.enabled"                                           = true
      "tracing.provider"                                          = "x-ray"
    }, lookup(var.helm, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
