aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
name       = "eks-appmesh"
tags = {
  env = "dev"
}
kubernetes_version = "1.20"
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
  }
]
