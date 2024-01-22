### Machine Learning with Kubeflow

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.7"
  name    = var.name
  tags    = var.tags
  vpc_config = {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

### eks
module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.11"
  name               = var.name
  tags               = var.tags
  subnets            = slice(values(module.vpc.subnets["private"]), 0, 3)
  enable_ssm         = true
  kubernetes_version = var.kubernetes_version
  managed_node_groups = [
    {
      name          = "kubeflow"
      min_size      = 1
      max_size      = 9
      desired_size  = 6
      instance_type = "t3.xlarge"
    }
  ]
}

### kubeflow-manifests
resource "null_resource" "clone" {
  provisioner "local-exec" {
    command = "bash scripts/clone.sh -k $KUBEFLOW_RELEASE_VERSION -a $AWS_RELEASE_VERSION"
    environment = {
      KUBEFLOW_RELEASE_VERSION = "v1.6.1"
      AWS_RELEASE_VERSION      = "v1.6.1-aws-b1.0.0"
    }
  }
}

resource "null_resource" "clear" {
  depends_on = [module.kubeflow]
  provisioner "local-exec" {
    command = "rm -rf kubeflow-manifests"
  }
}

### helm-addons
provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

module "kubeflow" {
  depends_on         = [module.ebs-csi, null_resource.clone]
  source             = "./modules/kubeflow"
  tags               = var.tags
  kubeflow_helm_repo = var.kubeflow_helm_repo
}

module "airflow" {
  depends_on = [module.ebs-csi]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.11"
  tags       = var.tags
  addons = [
    {
      ### for more details, https://airflow.apache.org/docs/helm-chart/stable/index.html
      repository     = "https://airflow.apache.org"
      name           = "airflow"
      chart_name     = "airflow"
      chart_version  = "1.7.0"
      namespace      = "airflow"
      serviceaccount = "airflow"

      ### since airflow migration process, need to turn off waiting of the terraform helm release
      ### for more details, https://github.com/hashicorp/terraform-provider-helm/issues/742
      wait = false
    },
  ]
}

### security/policy
resource "aws_iam_policy" "mnts3" {
  name        = "csi-mnt-s3"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow CSI driver to access S3 bucket objects")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "MountpointFullBucketAccess"
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Sid = "MountpointFullObjectAccess"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}

### eks-addons
module "ebs-csi" {
  depends_on = [module.eks]
  source     = "Young-ook/eks/aws//modules/eks-addons"
  version    = "2.0.11"
  tags       = var.tags
  addons = [
    {
      name           = "aws-ebs-csi-driver"
      namespace      = "kube-system"
      serviceaccount = "ebs-csi-controller-sa"
      eks_name       = module.eks.cluster.name
      oidc           = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", module.aws.partition.partition),
      ]
    },
    {
      name           = "aws-mountpoint-s3-csi-driver"
      namespace      = "kube-system"
      serviceaccount = "s3-csi-driver-sa"
      eks_name       = module.eks.cluster.name
      oidc           = module.eks.oidc
      policy_arns    = [aws_iam_policy.mnts3.arn]
    },
  ]
}
