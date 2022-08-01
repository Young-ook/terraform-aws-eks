## kubernetes aws-load-balancer-controller

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-load-balancer-controller")
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = [aws_iam_policy.lbc.arn]
  tags           = var.tags
}

resource "aws_iam_policy" "lbc" {
  name        = local.name
  tags        = merge(local.default-tags, var.tags)
  description = format("Allow aws-load-balancer-controller to manage AWS resources")
  path        = "/"
  policy      = file("${path.module}/policy.json")
}

resource "helm_release" "lbc" {
  name             = lookup(var.helm, "name", local.default_helm_config["name"])
  chart            = lookup(var.helm, "chart", local.default_helm_config["chart"])
  version          = lookup(var.helm, "version", local.default_helm_config["version"])
  repository       = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])

  dynamic "set" {
    for_each = merge({
      "clusterName"                                               = var.cluster_name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa.arn
    }, lookup(var.helm, "vars", local.default_helm_config["vars"]))
    content {
      name  = set.key
      value = set.value
    }
  }
}
