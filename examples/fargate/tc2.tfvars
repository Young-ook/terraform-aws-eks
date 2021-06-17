aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2b"]
name       = "eks-fargate-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version = "1.19"
fargate_profiles = [
  {
    name      = "hello"
    namespace = "hello"
  },
]
managed_node_groups = [
  {
    name          = "hello"
    min_size      = 1
    max_size      = 1
    desired_size  = 1
    instance_type = "t3.small"
  }
]
