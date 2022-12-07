### EKS Blueprint

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

### vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.2"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

### eks cluster
module "eks" {
  source              = "Young-ook/eks/aws"
  version             = "1.7.11"
  name                = var.name
  tags                = var.tags
  subnets             = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  enable_ssm          = var.enable_ssm
  kubernetes_version  = var.kubernetes_version
  fargate_profiles    = (var.use_default_vpc ? [] : var.fargate_profiles)
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
}

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### eks-addons
module "eks-addons" {
  source = "../../modules/eks-addons"
  tags   = var.tags
  addons = [
    {
      name     = "vpc-cni"
      eks_name = module.eks.cluster.name
    },
    {
      name     = "coredns"
      eks_name = module.eks.cluster.name
    },
    {
      name     = "kube-proxy"
      eks_name = module.eks.cluster.name
    },
    {
      name     = "aws-ebs-csi-driver"
      eks_name = module.eks.cluster.name
    },
  ]
}

### helm-addons
module "helm-addons" {
  depends_on = [module.eks-addons]
  source     = "../../modules/helm-addons"
  tags       = var.tags
  addons = [
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "appmesh-controller"
      chart_name     = "appmesh-controller"
      namespace      = "kube-system"
      serviceaccount = "appmesh-controller"
      values = {
        "region"           = var.aws_region
        "tracing.enabled"  = true
        "tracing.provider" = "x-ray"
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/AWSAppMeshEnvoyAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSXRayDaemonWriteAccess", module.aws.partition.partition),
      ]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-cloudwatch-metrics"
      chart_name     = "aws-cloudwatch-metrics"
      namespace      = "kube-system"
      serviceaccount = "aws-cloudwatch-metrics"
      values = {
        "clusterName" = module.eks.cluster.name
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition)
      ]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-for-fluent-bit"
      chart_name     = "aws-for-fluent-bit"
      namespace      = "kube-system"
      serviceaccount = "aws-for-fluent-bit"
      values = {
        "cloudWatch.enabled"      = true
        "cloudWatch.region"       = var.aws_region
        "cloudWatch.logGroupName" = format("/aws/containerinsights/%s/application", module.eks.cluster.name)
        "firehose.enabled"        = false
        "kinesis.enabled"         = false
        "elasticsearch.enabled"   = false
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition)
      ]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-load-balancer-controller"
      chart_name     = "aws-load-balancer-controller"
      namespace      = "kube-system"
      serviceaccount = "aws-load-balancer-controller"
      values = module.eks.features.fargate_enabled ? {
        "vpcId"       = module.vpc.vpc.id
        "clusterName" = module.eks.cluster.name
        } : {
        "clusterName" = module.eks.cluster.name
      }
      oidc        = module.eks.oidc
      policy_arns = [aws_iam_policy.lbc.arn]
    },
    {
      repository     = "https://charts.karpenter.sh"
      name           = "karpenter"
      chart_name     = "karpenter"
      namespace      = "kube-system"
      serviceaccount = "karpenter"
      values = {
        "clusterName"                = module.eks.cluster.name
        "clusterEndpoint"            = module.eks.cluster.control_plane.endpoint
        "aws.defaultInstanceProfile" = module.eks.instance_profile.node_groups == null ? module.eks.instance_profile.managed_node_groups.arn : module.eks.instance_profile.node_groups.arn
      }
      oidc        = module.eks.oidc
      policy_arns = [aws_iam_policy.kpt.arn]
    },
    {
      repository     = "https://kubernetes-sigs.github.io/metrics-server/"
      name           = "metrics-server"
      chart_name     = "metrics-server"
      namespace      = "kube-system"
      serviceaccount = "metrics-server"
      values = {
        "args[0]" = "--kubelet-preferred-address-types=InternalIP"
      }
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-node-termination-handler"
      chart_name     = "aws-node-termination-handler"
      namespace      = "kube-system"
      serviceaccount = "aws-node-termination-handler"
    },
  ]
}

resource "aws_iam_policy" "lbc" {
  name        = "aws-loadbalancer-controller"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow aws-load-balancer-controller to manage AWS resources")
  policy      = file("${path.module}/aws-loadbalancer-controller-policy.json")
}

resource "aws_iam_policy" "kpt" {
  name        = "karpenter"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow karpenter to manage AWS resources")
  policy      = file("${path.module}/karpenter-policy.json")
}
