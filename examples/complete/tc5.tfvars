aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-tc5"
tags = {
  env  = "dev"
  test = "tc5"
}
kubernetes_version = "1.17"
managed_node_groups = [
  {
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
  }
]
