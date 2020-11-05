# ARM64 node groups example

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# eks
module "eks" {
  source             = "Young-ook/eks/aws"
  name               = var.name
  tags               = var.tags
  kubernetes_version = var.kubernetes_version
  node_groups        = var.node_groups
}
