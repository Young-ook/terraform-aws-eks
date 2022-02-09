aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-appmesh-tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
kubernetes_version = "1.20"
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    ami_type      = "AL2_x86_64"
    instance_type = "t3.large"
  }
]
