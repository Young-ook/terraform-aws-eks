## kubernetes cluster autoscaling - karpenter

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
  policy_arns    = [aws_iam_policy.karpenter.arn]
  tags           = var.tags
}

resource "aws_iam_policy" "karpenter" {
  name        = local.name
  description = format("Allow karpenter to manage AWS resources")
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "helm_release" "karpenter" {
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
