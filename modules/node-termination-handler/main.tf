## kubernetes node termination handler

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-node-termination-handler")
}

resource "helm_release" "node-termination-handler" {
  count           = var.enabled ? 1 : 0
  name            = lookup(var.helm, "name", "aws-node-termination-handler")
  chart           = lookup(var.helm, "chart", "aws-node-termination-handler")
  version         = lookup(var.helm, "version", null)
  repository      = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  namespace       = local.namespace
  cleanup_on_fail = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({}, lookup(var.helm, "values", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
