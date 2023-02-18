### EKS FinOps

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

### vpc
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

### eks cluster
module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.3"
  name               = var.name
  tags               = var.tags
  subnets            = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  enable_ssm         = var.enable_ssm
  kubernetes_version = var.kubernetes_version
  managed_node_groups = [
    {
      name          = "default"
      min_size      = 1
      max_size      = 3
      desired_size  = 3
      instance_type = "t3.xlarge"
    },
  ]
}

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### helm-addons
module "helm-addons" {
  depends_on = [module.eks]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.3"
  tags       = var.tags
  addons = [
    {
      repository     = "https://cloudforet-io.github.io/charts"
      name           = "spaceone"
      chart_name     = "spaceone"
      chart_version  = "1.10.4"
      namespace      = "spaceone"
      serviceaccount = "spaceone"
      values = {
        "console.production_json.CONSOLE_API.ENDPOINT" = "http://localhost:8081"
        "console.ingress.enabled"                      = false
        "console-api.ingress.enabled"                  = false
        "console-api-v2.enabled"                       = false
        "cost-analysis.scheduler"                      = false
        "inventory.scheduler"                          = false
        "monitoring.scheduler"                         = false
        "plugin.scheduler"                             = false
        "spot-automation.scheduler"                    = false
        "statistics.scheduler"                         = false
      }
    },
  ]
}
