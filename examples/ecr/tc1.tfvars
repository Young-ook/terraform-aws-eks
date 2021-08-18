aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-ecr-tc1"
tags = {
  env      = "dev"
  platform = "fargate"
  test     = "tc1"
}
kubernetes_version  = "1.21"
managed_node_groups = []
node_groups         = []
fargate_profiles = [
  {
    name      = "hello"
    namespace = "hello"
  },
]
