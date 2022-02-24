# Machine Learning with Kubeflow

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source = "Young-ook/vpc/aws"
  name   = var.name
  tags   = var.tags
  vpc_config = {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  subnets             = slice(values(module.vpc.subnets["private"]), 0, 3)
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
  fargate_profiles    = var.fargate_profiles
  enable_ssm          = true
}

resource "local_file" "kfinst" {
  content = templatefile("${path.module}/templates/kfinst.tpl", {
    aws_region = var.aws_region
    eks_name   = module.eks.cluster.name
    eks_role   = module.eks.role.arn
  })
  filename        = "${path.module}/kfinst.sh"
  file_permission = "0700"
}

resource "local_file" "kfuninst" {
  content         = templatefile("${path.module}/templates/kfuninst.tpl", {})
  filename        = "${path.module}/kfuninst.sh"
  file_permission = "0700"
}
