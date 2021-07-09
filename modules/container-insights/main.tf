## kubernetes container-insights

module "irsa-metrics" {
  source         = "../iam-role-for-serviceaccount"
  count          = var.enabled ? 1 : 0
  name           = join("-", compact(["irsa", var.cluster_name, "amazon-cloudwatch", local.suffix]))
  namespace      = "amazon-cloudwatch"
  serviceaccount = "amazon-cloudwatch"
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  tags           = var.tags
}

resource "helm_release" "metrics" {
  count            = var.enabled ? 1 : 0
  name             = "aws-cloudwatch-metrics"
  chart            = "aws-cloudwatch-metrics"
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  namespace        = "amazon-cloudwatch"
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.cluster_name
      "serviceAccount.name"                                       = "amazon-cloudwatch"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa-metrics[0].arn[0]
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

module "irsa-logs" {
  source         = "../iam-role-for-serviceaccount"
  count          = var.enabled ? 1 : 0
  name           = join("-", compact(["irsa", var.cluster_name, "aws-for-fluent-bit", local.suffix]))
  namespace      = "kube-system"
  serviceaccount = "aws-for-fluent-bit"
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  tags           = var.tags
}

resource "helm_release" "logs" {
  count           = var.enabled ? 1 : 0
  name            = "aws-for-fluent-bit"
  chart           = "aws-for-fluent-bit"
  version         = lookup(var.helm, "version", null)
  repository      = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  namespace       = "kube-system"
  cleanup_on_fail = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "cloudWatch.enabled"                                        = true
      "cloudWatch.region"                                         = data.aws_region.current.0.name
      "cloudWatch.logGroupName"                                   = format("/aws/containerinsights/%s/application", var.cluster_name)
      "firehose.enabled"                                          = false
      "kinesis.enabled"                                           = false
      "elasticsearch.enabled"                                     = false
      "serviceAccount.name"                                       = "aws-for-fluent-bit"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa-logs[0].arn[0]
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
