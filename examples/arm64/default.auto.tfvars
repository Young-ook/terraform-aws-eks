aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-arm64"
tags = {
  env  = "dev"
  arch = "arm64"
}
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "arm64"
    min_size      = 1
    max_size      = 1
    desired_size  = 1
    instance_type = "m6g.medium"
    ami_type      = "AL2_ARM_64"
  }
]
