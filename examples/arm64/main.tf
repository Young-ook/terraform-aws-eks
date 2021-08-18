# ARM64 node groups example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  alias  = "codebuild"
  region = "ap-northeast-1"
}

provider "aws" {
  region = var.aws_region
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
