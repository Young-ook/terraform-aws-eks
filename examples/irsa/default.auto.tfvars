name = "eks-irsa"
tags = {
  env = "dev"
}
aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr               = "10.1.0.0/16"
enable_igw         = true
enable_ngw         = true
single_ngw         = true
kubernetes_version = "1.19"
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
]
