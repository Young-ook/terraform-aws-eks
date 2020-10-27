# Complete example

terraform {
  required_version = "~> 0.13"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# eks
module "eks" {
  source                     = "Young-ook/eks/aws"
  name                       = var.name
  tags                       = var.tags
  kubernetes_version         = var.kubernetes_version
  managed_node_groups        = var.managed_node_groups
  node_groups                = var.node_groups
  container_insights_enabled = true
  app_mesh_enabled           = true
}

module "irsa" {
  source         = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"
  name           = join("-", ["irsa", var.name, "s3readonly"])
  namespace      = "default"
  serviceaccount = "irsa-test"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = var.tags
}
