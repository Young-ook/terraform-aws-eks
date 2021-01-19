## kubernetes prometheus

locals {
  namespace      = lookup(var.helm, "namespace", "prometheus")
  serviceaccount = lookup(var.helm, "serviceaccount", "prometheus")
}

resource "helm_release" "prometheus" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "prometheus")
  chart            = lookup(var.helm, "chart", "prometheus")
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", "https://prometheus-community.github.io/helm-charts")
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({}, lookup(var.helm, "values", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
