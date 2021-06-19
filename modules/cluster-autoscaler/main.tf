## kubernetes cluster autoscaler

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "cluster-autoscaler")
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
  count          = var.enabled ? 1 : 0
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = [aws_iam_policy.autoscaler.0.arn]
  tags           = var.tags
}

resource "aws_iam_policy" "autoscaler" {
  count       = var.enabled ? 1 : 0
  name        = local.name
  description = format("Allow cluster-autoscaler to manage AWS resources")
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
      ]
      Effect   = "Allow"
      Resource = ["*"]
    }]
    Version = "2012-10-17"
  })
}

resource "helm_release" "autoscaler" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "cluster-autoscaler")
  chart            = lookup(var.helm, "chart", "cluster-autoscaler")
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", join("/", [path.module, "charts"]))
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "autoDiscovery.clusterName"                                 = var.cluster_name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa[0].arn[0]
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
