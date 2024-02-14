### EKS Blueprint

terraform {
  required_version = "~> 1.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
  }
}

provider "aws" {
  region = var.aws_region

  // This is necessary so that tags required for eks can be applied to the vpc without changes to the vpc wiping them out.
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging
  // https://stackoverflow.com/questions/57495581/terraform-eks-tagging
  ignore_tags {
    key_prefixes = ["kubernetes.io/", "karpenter.sh/"]
  }
}

### vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.7"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }

  # Amazon ECS tasks using the Fargate launch type and platform version 1.3.0 or earlier only require
  # the com.amazonaws.region.ecr.dkr Amazon ECR VPC endpoint and the Amazon S3 gateway endpoints.
  #
  # Amazon ECS tasks using the Fargate launch type and platform version 1.4.0 or later require both
  # the com.amazonaws.region.ecr.dkr and com.amazonaws.region.ecr.api Amazon ECR VPC endpoints and
  # the Amazon S3 gateway endpoints.
  #
  # For more details, please visit the https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
  vpce_config = [
    {
      service             = "ecr.dkr"
      type                = "Interface"
      private_dns_enabled = false
    },
    {
      service             = "ecr.api"
      type                = "Interface"
      private_dns_enabled = true
    },
    # For more details, please refer to this web page, https://aws.amazon.com/about-aws/whats-new/2022/12/amazon-eks-supports-aws-privatelink/
    {
      service             = "eks"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service = "s3"
      type    = "Gateway"
    },
    {
      service             = "guardduty-data"
      type                = "Interface"
      private_dns_enabled = true
    },
  ]
}

### karpenter discovery tags
resource "aws_ec2_tag" "karpenter-subnets" {
  for_each    = toset(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]))
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = module.eks.cluster.name
}

resource "aws_ec2_tag" "karpenter-security-groups" {
  resource_id = module.eks.cluster.control_plane.vpc_config.0.cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = module.eks.cluster.name
}

### eks cluster
module "eks" {
  source              = "Young-ook/eks/aws"
  version             = "2.0.10"
  name                = var.name
  tags                = var.tags
  subnets             = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  enable_ssm          = var.enable_ssm
  kubernetes_version  = var.kubernetes_version
  fargate_profiles    = (var.use_default_vpc ? [] : var.fargate_profiles)
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
}

### kubernetes addons
provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

module "kubernetes-addons" {
  depends_on = [module.eks]
  source     = "./modules/kubernetes-addons"
  tags       = var.tags
  eks        = module.eks
  vpc        = module.vpc
  features   = local.toggles
}
