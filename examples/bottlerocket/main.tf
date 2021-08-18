# Bottle Rocket OS example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# eks
module "eks" {
  source              = "../../"
  name                = var.name
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
  fargate_profiles    = var.fargate_profiles
  enable_ssm          = var.enable_ssm
}
