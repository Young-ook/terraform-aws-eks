# ARM64 node groups example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### network/vpc
module "vpc" {
  source = "Young-ook/vpc/aws"
  name   = var.name
  tags   = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

### cluster/eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  subnets             = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
}

### artifact/ecr
module "ecr" {
  providers    = { aws = aws.codebuild }
  source       = "Young-ook/eks/aws//modules/ecr"
  name         = "hello-nodejs"
  scan_on_push = false
}
