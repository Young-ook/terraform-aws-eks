## helm

provider "helm" {
  kubernetes {
    host                   = lookup(var.helm, "host", local.default_eks_config["host"])
    token                  = lookup(var.helm, "token", local.default_eks_config["token"])
    cluster_ca_certificate = lookup(var.helm, "ca_certificate", local.default_eks_config["cluster_ca_certificate"])
  }
}

resource "helm_release" "helm" {
  name             = lookup(var.helm, "name", local.default_helm_config["name"])
  chart            = lookup(var.helm, "chart", local.default_helm_config["chart"])
  version          = lookup(var.helm, "version", local.default_helm_config["version"])
  repository       = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace        = lookup(var.helm, "namespace", local.default_helm_config["namespace"])
  create_namespace = lookup(var.helm, "create_namespace", local.default_helm_config["create_namespace"])
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])

  dynamic "set" {
    for_each = lookup(var.helm, "values", local.default_helm_config["values"])
    content {
      name  = set.key
      value = set.value
    }
  }
}
