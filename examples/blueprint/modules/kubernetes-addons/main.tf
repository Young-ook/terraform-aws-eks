### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### security/policy
resource "aws_iam_policy" "lbc" {
  name        = "aws-loadbalancer-controller"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow aws-load-balancer-controller to manage AWS resources")
  policy      = file("${path.module}/policy.aws-loadbalancer-controller.json")
}

resource "aws_iam_policy" "cas" {
  name        = "cluster-autoscaler"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow cluster-autoscaler to manage AWS resources")
  policy      = file("${path.module}/policy.cluster-autoscaler.json")
}

resource "aws_iam_policy" "kpt" {
  name        = "karpenter"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow karpenter to manage AWS resources")
  policy      = file("${path.module}/policy.karpenter.json")
}

### helm-addons
module "base" {
  source  = "Young-ook/eks/aws//modules/helm-addons"
  version = "2.0.3"
  tags    = merge(var.tags, local.default-tags)
  addons = [
    {
      ### for more details, https://cert-manager.io/docs/installation/helm/
      repository       = "https://charts.jetstack.io"
      name             = "cert-manager"
      chart_name       = "cert-manager"
      chart_version    = "v1.11.2"
      namespace        = "cert-manager"
      create_namespace = true
      values = {
        "installCRDs" = "true"
      }
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
  ]
}

module "ctl" {
  depends_on = [module.base]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.3"
  tags       = var.tags
  addons = [
    {
      ### You can disable the mutator webhook feature by setting the helm chart value enableServiceMutatorWebhook to false.
      ### https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/tag/v2.5.1
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-load-balancer-controller"
      chart_name     = "aws-load-balancer-controller"
      chart_version  = "1.5.2"
      namespace      = "kube-system"
      serviceaccount = "aws-load-balancer-controller"
      values = var.eks.features.fargate_enabled ? {
        "vpcId"                       = var.vpc.vpc.id
        "clusterName"                 = var.eks.cluster.name
        "enableServiceMutatorWebhook" = "false"
        } : {
        "clusterName"                 = var.eks.cluster.name
        "enableServiceMutatorWebhook" = "false"
      }
      oidc        = var.eks.oidc
      policy_arns = [aws_iam_policy.lbc.arn]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-cloudwatch-metrics"
      chart_name     = "aws-cloudwatch-metrics"
      namespace      = "kube-system"
      serviceaccount = "aws-cloudwatch-metrics"
      values = {
        "clusterName" = var.eks.cluster.name
      }
      oidc = var.eks.oidc
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
        "cloudWatch.region"       = module.aws.region.id
        "cloudWatch.logGroupName" = format("/aws/containerinsights/%s/application", var.eks.cluster.name)
        "firehose.enabled"        = false
        "kinesis.enabled"         = false
        "elasticsearch.enabled"   = false
      }
      oidc = var.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition)
      ]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-node-termination-handler"
      chart_name     = "aws-node-termination-handler"
      namespace      = "kube-system"
      serviceaccount = "aws-node-termination-handler"
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "appmesh-controller"
      chart_name     = "appmesh-controller"
      namespace      = "kube-system"
      serviceaccount = "appmesh-controller"
      values = {
        "region"           = module.aws.region.id
        "tracing.enabled"  = true
        "tracing.provider" = "x-ray"
      }
      oidc = var.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/AWSAppMeshEnvoyAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSXRayDaemonWriteAccess", module.aws.partition.partition),
      ]
    },
    {
      ### If you are getting a 403 forbidden error, try 'docker logout public.ecr.aws'
      ### https://karpenter.sh/preview/troubleshooting/#helm-error-when-pulling-the-chart
      repository     = null
      name           = "karpenter"
      chart_name     = "oci://public.ecr.aws/karpenter/karpenter"
      chart_version  = "v0.27.1"
      namespace      = "karpenter"
      serviceaccount = "karpenter"
      values = {
        "settings.aws.clusterName"            = var.eks.cluster.name
        "settings.aws.clusterEndpoint"        = var.eks.cluster.control_plane.endpoint
        "settings.aws.defaultInstanceProfile" = var.eks.instance_profile.node_groups == null ? var.eks.instance_profile.managed_node_groups.arn : var.eks.instance_profile.node_groups.arn
      }
      oidc        = var.eks.oidc
      policy_arns = [aws_iam_policy.kpt.arn]
    },
    {
      repository     = "${path.module}/charts/"
      name           = "cluster-autoscaler"
      chart_name     = "cluster-autoscaler"
      namespace      = "kube-system"
      serviceaccount = "cluster-autoscaler"
      values = {
        "awsRegion"                 = module.aws.region.id
        "autoDiscovery.clusterName" = var.eks.cluster.name
      }
      oidc        = var.eks.oidc
      policy_arns = [aws_iam_policy.cas.arn]
    },
  ]
}

module "spinnaker" {
  depends_on = [module.eks-addons]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.4"
  tags       = var.tags
  addons = [
    {
      repository        = "${path.module}/charts/"
      name              = "spinnaker"
      chart_name        = "spinnaker"
      namespace         = "spinnaker"
      dependency_update = true
      values = {
        "spinnaker.version"  = "1.30.0"
        "halyard.image.tag"  = "1.44.0"
        "minio.rootUser"     = "spinnakeradmin"
        "minio.rootPassword" = "spinnakeradmin"
      }
    },
  ]
}

### eks-addons
module "eks-addons" {
  ### the adot-addon requires a cert-manager from helm-addons
  depends_on = [module.ctl]
  source     = "Young-ook/eks/aws//modules/eks-addons"
  version    = "2.0.3"
  tags       = var.tags
  addons = [
    {
      name     = "vpc-cni"
      eks_name = var.eks.cluster.name
    },
    {
      name     = "coredns"
      eks_name = var.eks.cluster.name
    },
    {
      name     = "kube-proxy"
      eks_name = var.eks.cluster.name
    },
    {
      name           = "aws-ebs-csi-driver"
      namespace      = "kube-system"
      serviceaccount = "ebs-csi-controller-sa"
      eks_name       = var.eks.cluster.name
      oidc           = var.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", module.aws.partition.partition),
      ]
    },
    {
      name           = "adot"
      namespace      = "default"
      serviceaccount = "adot-collector"
      eks_name       = var.eks.cluster.name
      oidc           = var.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/AmazonPrometheusRemoteWriteAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSXrayWriteOnlyAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition),
      ]
    },
  ]
}
