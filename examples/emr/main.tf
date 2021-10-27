# Amazon EMR on Amazon EKS

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### application/eks
module "eks" {
  source              = "Young-ook/eks/aws"
  name                = var.name
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  enable_ssm          = var.enable_ssm
}

resource "local_file" "create-emr-virtual-cluster-request-json" {
  content = templatefile("${path.module}/templates/create-emr-virtual-cluster-request.tpl", {
    emr_name = var.name
    eks_name = module.eks.cluster.name
  })
  filename        = "${path.module}/create-emr-virtual-cluster-request.json"
  file_permission = "0600"
}

resource "local_file" "create-emr-virtual-cluster-cli" {
  depends_on = [local_file.create-emr-virtual-cluster-request-json, ]
  content = templatefile("${path.module}/templates/create-emr-virtual-cluster.tpl", {
    aws_region = var.aws_region
  })
  filename        = "${path.module}/create-emr-virtual-cluster.sh"
  file_permission = "0600"
}

resource "local_file" "delete-emr-virtual-cluster-cli" {
  content = templatefile("${path.module}/templates/delete-emr-virtual-cluster.tpl", {
    aws_region = var.aws_region
  })
  filename        = "${path.module}/delete-emr-virtual-cluster.sh"
  file_permission = "0600"
}
