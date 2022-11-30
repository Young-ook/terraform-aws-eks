### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  helm_addons = {
    app-mesh = {
      chart_name    = "appmesh-controller"
      chart_version = null
      values        = {}
      policy_arns = [
        format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSAppMeshFullAccess", module.aws.partition.partition),
      ]
    }
  }
}

### application/chart
resource "helm_release" "chart" {
  for_each         = lookup(local.helm_addons, var.name, {})
  name             = lookup(each.value, "chart_name")
  chart            = lookup(each.value, "chart_name")
  version          = lookup(each.value, "chart_version")
  repository       = lookup(each.value, "repository")
  namespace        = lookup(each.value, "namespace")
  create_namespace = true
  cleanup_on_fail  = true

  dynamic "set" {
    for_each = lookup(each.value, "values", {})
    content {
      name  = set.key
      value = set.value
    }
  }
}

### security/policy
module "irsa" {
  for_each       = lookup(local.helm_addons, var.name, {})
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  version        = "1.7.10"
  name           = module.frigga.name
  tags           = merge(local.default-tags, var.tags)
  namespace      = var.namespace
  serviceaccount = var.serviceaccount
  oidc_url       = lookup(var.oidc, "url")
  oidc_arn       = lookup(var.oidc, "arn")
  policy_arns    = lookup(each.value, "policy_arns", [])
}
