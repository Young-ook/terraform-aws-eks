### Analytics on Amazon EKS

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### network/vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

### platform/eks
module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.3"
  name               = var.name
  tags               = var.tags
  subnets            = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  kubernetes_version = var.kubernetes_version
  enable_ssm         = var.enable_ssm
  managed_node_groups = [
    {
      name          = "spark"
      desired_size  = 3
      min_size      = 3
      max_size      = 9
      instance_type = "m5.large"
    }
  ]
}

### eks-addons
module "eks-addons" {
  depends_on = [module.eks]
  source     = "Young-ook/eks/aws//modules/eks-addons"
  version    = "2.0.3"
  tags       = var.tags
  addons = [
    {
      name           = "aws-ebs-csi-driver"
      namespace      = "kube-system"
      serviceaccount = "ebs-csi-controller-sa"
      eks_name       = module.eks.cluster.name
      oidc           = module.eks.oidc
      policy_arns    = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
    },
  ]
}

### helm-addons
provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

module "airflow" {
  depends_on = [module.eks-addons]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.4"
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

### artifact/bucket
module "s3" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  version       = "0.3.2"
  name          = var.name
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

### platform/emr
module "emr" {
  source = "./modules/emr-containers"
  name   = var.name
  container_providers = {
    id = module.eks.cluster.name
  }
}
