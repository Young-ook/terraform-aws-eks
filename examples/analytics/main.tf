# Amazon EMR on Amazon EKS

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

# eks
module "eks" {
  source             = "Young-ook/eks/aws"
  name               = var.name
  tags               = var.tags
  subnets            = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  kubernetes_version = var.kubernetes_version
  enable_ssm         = var.enable_ssm
  managed_node_groups = [
    {
      name          = "spark"
      desired_size  = 3
      min_size      = 3
      max_size      = 9
      instance_type = "m5.large"
    }
  ]
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
