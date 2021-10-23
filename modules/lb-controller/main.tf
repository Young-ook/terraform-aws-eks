## kubernetes aws-load-balancer-controller

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-load-balancer-controller")
  // https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  region_to_image_account_mapping = {
    "af-south-1"     = "877085696533"
    "ap-east-1"      = "800184023465"
    "ap-northeast-1" = "602401143452"
    "ap-northeast-2" = "602401143452"
    "ap-northeast-3" = "602401143452"
    "ap-south-1"     = "602401143452"
    "ap-southeast-1" = "602401143452"
    "ap-southeast-2" = "602401143452"
    "ca-central-1"   = "602401143452"
    "cn-north-1"     = "918309763551"
    "cn-northwest-1" = "961992271922"
    "eu-central-1"   = "602401143452"
    "eu-north-1"     = "602401143452"
    "eu-south-1"     = "590381155156"
    "eu-west-1"      = "602401143452"
    "eu-west-2"      = "602401143452"
    "eu-west-3"      = "602401143452"
    "me-south-1"     = "558608220178"
    "sa-east-1"      = "602401143452"
    "us-east-1"      = "602401143452"
    "us-east-2"      = "602401143452"
    "us-gov-east-1"  = "151742754352"
    "us-gov-west-1"  = "013241004608"
    "us-west-1"      = "602401143452"
    "us-west-2"      = "602401143452"
  }
  // if china region, append .cn
  image_domain      = trimprefix(var.region, "cn-") != var.region ? "amazonaws.com.cn" : "amazonaws.com"
  region_image_repo = "${lookup(local.region_to_image_account_mapping, var.region, "us-west-2")}.dkr.ecr.${var.region}.${local.image_domain}/amazon/aws-load-balancer-controller"
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
  count          = var.enabled ? 1 : 0
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = var.oidc.url
  oidc_arn       = var.oidc.arn
  policy_arns    = [aws_iam_policy.lbc.0.arn]
  tags           = var.tags
}

resource "aws_iam_policy" "lbc" {
  count       = var.enabled ? 1 : 0
  name        = local.name
  description = format("Allow aws-load-balancer-controller to manage AWS resources")
  path        = "/"
  policy      = file("${path.module}/policy.json")
}

resource "helm_release" "lbc" {
  count           = var.enabled ? 1 : 0
  name            = lookup(var.helm, "name", "aws-load-balancer-controller")
  chart           = lookup(var.helm, "chart", "aws-load-balancer-controller")
  version         = lookup(var.helm, "version", null)
  repository      = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  namespace       = local.namespace
  cleanup_on_fail = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.cluster_name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa[0].arn[0]
      "region"                                                    = var.region
      "vpcId"                                                     = var.vpc_id
      "image.repository"                                          = local.region_image_repo
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
