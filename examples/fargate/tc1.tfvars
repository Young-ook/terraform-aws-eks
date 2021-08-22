aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-fargate-tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
kubernetes_version = "1.21"
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
]
