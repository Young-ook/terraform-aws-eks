## kubernetes cluster autoscaler

locals {
  namespace      = lookup(var.helm, "namespace", local.default_helm_config["namespace"])
  serviceaccount = lookup(var.helm, "serviceaccount", local.default_helm_config["serviceaccount"])
}

module "irsa" {
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = [aws_iam_policy.autoscaler.arn]
  tags           = var.tags
}

resource "aws_iam_policy" "autoscaler" {
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
  name             = lookup(var.helm, "name", local.default_helm_config["name"])
  chart            = lookup(var.helm, "chart", local.default_helm_config["chart"])
  version          = lookup(var.helm, "version", local.default_helm_config["version"])
  repository       = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])

  dynamic "set" {
    for_each = merge({
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa.arn
    }, lookup(var.helm, "vars", local.default_helm_config["vars"]))
    content {
      name  = set.key
      value = set.value
    }
  }
}
