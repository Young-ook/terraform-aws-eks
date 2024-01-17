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

resource "aws_iam_policy" "spin" {
  for_each    = (try(var.features.spinnaker_enabled, false) ? toset(["enabled"]) : [])
  name        = "spinnaker-assume-role"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow spinnaker to manage AWS resources")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

### helm-addons
module "base" {
  source  = "Young-ook/eks/aws//modules/helm-addons"
  version = "2.0.10"
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
  version    = "2.0.10"
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
    {
      repository    = "https://kedacore.github.io/charts"
      name          = "keda"
      chart_name    = "keda"
      chart_version = "2.12.1"
      namespace     = "keda"
    },
  ]
}

module "devops" {
  depends_on = [module.eks-addons]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.10"
  tags       = var.tags
  addons = concat((try(var.features.spinnaker_enabled, false) ?
    [
      {
        repository        = "${path.module}/charts/"
        name              = "spinnaker"
        chart_name        = "spinnaker"
        namespace         = "spinnaker"
        serviceaccount    = "default"
        dependency_update = true
        values = {
          "spinnaker.version"  = "1.33.0"
          "halyard.image.tag"  = "1.44.0"
          "minio.rootUser"     = "spinnakeradmin"
          "minio.rootPassword" = "spinnakeradmin"
        }
        oidc        = var.eks.oidc
        policy_arns = [aws_iam_policy.spin["enabled"].arn]
      },
    ] : []),
    [
      {
        repository     = "https://charts.chaos-mesh.org"
        name           = "chaos-mesh"
        chart_name     = "chaos-mesh"
        namespace      = "chaos-mesh"
        serviceaccount = "chaos-mesh-controller"
      },
  ])
}

### eks-addons
module "eks-addons" {
  ### the adot-addon requires a cert-manager from helm-addons
  depends_on = [module.ctl]
  source     = "Young-ook/eks/aws//modules/eks-addons"
  version    = "2.0.10"
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
    {
      name           = "amazon-cloudwatch-observability"
      namespace      = "amazon-cloudwatch"
      serviceaccount = "cloudwatch-agent"
      eks_name       = var.eks.cluster.name
      oidc           = var.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/AWSXrayWriteOnlyAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition),
      ]
    },
    {
      name      = "kubecost_kubecost"
      namespace = "kubecost"
      eks_name  = var.eks.cluster.name
    },
    {
      name     = "eks-pod-identity-agent"
      eks_name = var.eks.cluster.name
    },
    {
      name     = "aws-guardduty-agent"
      eks_name = var.eks.cluster.name
    },
  ]
}

module "apps" {
  depends_on = [module.eks-addons]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.6"
  tags       = var.tags
  addons = [
    {
      ### for more information about the NATS helm chart, please refer to the artifacthub or github.
      ### artifacthub: https://artifacthub.io/packages/helm/nats/nats
      ### github: https://github.com/nats-io/k8s/tree/main/helm/charts/nats
      repository    = "https://nats-io.github.io/k8s/helm/charts/"
      name          = "nats"
      chart_name    = "nats"
      chart_version = "1.1.5"
      namespace     = "nats"
    },
  ]
}
