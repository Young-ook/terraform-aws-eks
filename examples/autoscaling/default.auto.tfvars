aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-autoscaling"
tags = {
  env = "dev"
}
kubernetes_version = "1.20"
managed_node_groups = [
  {
    name          = "default"
    max_size      = 6
    instance_type = "t3.small"
  }
]
node_groups      = []
fargate_profiles = []
