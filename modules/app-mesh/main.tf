## kubernetes aws-app-mesh-controller

# aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  namespace      = lookup(var.helm, "namespace")
  serviceaccount = lookup(var.helm, "serviceaccount")
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
  name             = lookup(var.helm, "name")
  chart            = lookup(var.helm, "chart")
  version          = lookup(var.helm, "version")
  repository       = lookup(var.helm, "repository")
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail")

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
