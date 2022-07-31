## kubernetes chaos-mesh

# aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  namespace      = lookup(var.helm, "namespace")
  serviceaccount = lookup(var.helm, "serviceaccount")
}

resource "helm_release" "chaosmesh" {
  name             = lookup(var.helm, "name")
  chart            = lookup(var.helm, "chart")
  version          = lookup(var.helm, "version")
  repository       = lookup(var.helm, "repository")
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail")

  dynamic "set" {
    for_each = merge({}, lookup(var.helm, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
