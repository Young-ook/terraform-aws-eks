## kubernetes metrics-server

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "metrics-server")
}

resource "helm_release" "metrics" {
  name            = lookup(var.helm, "name", "metrics-server")
  chart           = lookup(var.helm, "chart", "metrics-server")
  version         = lookup(var.helm, "version", null)
  repository      = lookup(var.helm, "repository", "https://charts.helm.sh/stable")
  namespace       = local.namespace
  cleanup_on_fail = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({
      "args[0]" = "--kubelet-preferred-address-types=InternalIP"
    }, lookup(var.helm, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
