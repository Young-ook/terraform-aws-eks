name = "eks-fis"
tags = {
  env = "prod"
}
aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr               = "10.1.0.0/16"
kubernetes_version = "1.20"
