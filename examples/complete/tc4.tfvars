aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-tc4"
tags = {
  env  = "dev"
  test = "tc4"
}
kubernetes_version = "1.17"
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
  {
    name      = "hello"
    namespace = "hello"
  },
]
