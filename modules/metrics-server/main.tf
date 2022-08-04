## kubernetes metrics-server

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "metrics-server")
}

resource "helm_release" "metrics" {
  name             = lookup(var.helm, "name", local.default_helm_config["name"])
  chart            = lookup(var.helm, "chart", local.default_helm_config["chart"])
  version          = lookup(var.helm, "version", local.default_helm_config["version"])
  repository       = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])

  dynamic "set" {
    for_each = merge({
      "args[0]" = "--kubelet-preferred-address-types=InternalIP"
    }, lookup(var.helm, "vars", local.default_helm_config["vars"]))
    content {
      name  = set.key
      value = set.value
    }
  }
}
