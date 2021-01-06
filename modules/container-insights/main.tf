## kubernetes container-insights

locals {
  namespace      = lookup(var.helm, "namespace", "amazon-cloudwatch")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-container-insights")
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
  count          = var.enabled ? 1 : 0
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = [aws_iam_policy.containerinsights.0.arn]
  tags           = var.tags
}

resource "aws_iam_policy" "containerinsights" {
  count       = var.enabled ? 1 : 0
  name        = local.name
  description = format("Allow cloudwatch-agent to manage AWS CloudWatch logs for ContainerInsights")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = [format("arn:${data.aws_partition.current.0.partition}:logs:*:*:*")]
      },
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "helm_release" "containerinsights" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "eks-cw")
  chart            = lookup(var.helm, "chart", "container-insights")
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", join("/", [path.module, "charts"]))
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "cluster.name"                                              = var.cluster_name
      "cluster.region"                                            = data.aws_region.current.0.name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa[0].arn[0]
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
