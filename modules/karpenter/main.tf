## kubernetes cluster autoscaling

locals {
  namespace      = lookup(var.helm, "namespace", "karpenter")
  serviceaccount = lookup(var.helm, "serviceaccount", "karpenter")
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
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
  name             = lookup(var.helm, "name", "karpenter")
  chart            = lookup(var.helm, "chart", "karpenter")
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", join("/", [path.module, "charts"]))
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({
      "clusterName"                                               = lookup(var.helm.vars, "cluster_name")
      "clusterEndpoint"                                           = lookup(var.helm.vars, "cluster_endpoint")
      "aws.defaultInstanceProfile"                                = lookup(var.helm.vars, "default_instance_profile")
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa.arn
    }, lookup(var.helm, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
