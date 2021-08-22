aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-fargate"
tags = {
  env = "dev"
}
kubernetes_version = "1.21"
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
]
