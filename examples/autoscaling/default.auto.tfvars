aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-autoscaling"
tags = {
  env = "dev"
}
kubernetes_version  = "1.20"
managed_node_groups = []
node_groups         = []
fargate_profiles    = []
