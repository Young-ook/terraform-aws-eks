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

locals {
  aws = {
    dns    = module.aws.partition.dns_suffix
    region = module.aws.region.name
  }
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
  depends_on         = [module.csi, null_resource.clone]
  source             = "./modules/kubeflow"
  tags               = var.tags
  kubeflow_helm_repo = var.kubeflow_helm_repo
}

module "airflow" {
  depends_on = [module.csi]
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

### stoage
module "s3" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  version       = "0.4.7"
  tags          = var.tags
  force_destroy = true
  lifecycle_rules = [
    {
      id     = "s3-intelligent-tiering"
      status = "Enabled"
      filter = {
        prefix = ""
      }
      transition = [
        {
          days          = 0
          storage_class = "INTELLIGENT_TIERING"
        },
      ]
    },
  ]
}

### eks-addons
module "csi" {
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
      policy_arns    = [module.s3.policy_arns["read"], module.s3.policy_arns["write"]]
    },
  ]
}
