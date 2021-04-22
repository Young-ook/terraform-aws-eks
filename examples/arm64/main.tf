# ARM64 node groups example

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  alias               = "codebuild"
  region              = "ap-northeast-1"
  allowed_account_ids = [var.aws_account_id]
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# build container image
module "codebuild" {
  providers = { aws = aws.codebuild }
  source    = "./modules/codebuild"
  name      = var.name
  tags      = var.tags
}

# eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
}
