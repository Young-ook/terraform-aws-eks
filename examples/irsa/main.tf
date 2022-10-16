# IAM Role for Service Accounts example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name                = var.name
  tags                = merge(var.tags, module.eks.tags.shared)
  azs                 = var.azs
  cidr                = var.cidr
  enable_igw          = var.enable_igw
  enable_ngw          = var.enable_ngw
  single_ngw          = var.single_ngw
  vpc_endpoint_config = []
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  version             = "1.7.10"
  name                = var.name
  tags                = var.tags
  subnets             = values(module.vpc.subnets["private"])
  kubernetes_version  = var.kubernetes_version
  fargate_profiles    = var.fargate_profiles
  managed_node_groups = var.managed_node_groups
}

module "irsa" {
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  version        = "1.7.10"
  name           = join("-", ["irsa", var.name, "s3-readonly"])
  namespace      = "default"
  serviceaccount = "s3-readonly"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = var.tags
}
