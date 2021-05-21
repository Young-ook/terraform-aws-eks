# AWS Fault Injection Simulator

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region = var.aws_region
}

### foundation/network
# vpc
module "vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name                = var.name
  tags                = var.tags
  azs                 = var.azs
  cidr                = var.cidr
  enable_igw          = true
  enable_ngw          = true
  single_ngw          = true
  vpc_endpoint_config = []
}

### application/eks
module "eks" {
  source             = "Young-ook/eks/aws"
  name               = var.name
  tags               = var.tags
  subnets            = values(module.vpc.subnets["private"])
  kubernetes_version = var.kubernetes_version
  enable_ssm         = true
  fargate_profiles = [
    {
      name      = "loadtest"
      namespace = "loadtest"
    },
  ]
  managed_node_groups = [
    {
      name          = "sockshop"
      min_size      = 1
      max_size      = 5
      desired_size  = 3
      instance_type = "t3.small"
    }
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "container-insights" {
  source       = "Young-ook/eks/aws//modules/container-insights"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
}

module "cluster-autoscaler" {
  source       = "Young-ook/eks/aws//modules/cluster-autoscaler"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
}

### application/monitoring
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = local.cw_cpu_alarm_name
  alarm_description         = "This metric monitors ec2 cpu utilization"
  tags                      = merge(local.default-tags, var.tags)
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 3
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 60
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = local.target_asg
  }
}