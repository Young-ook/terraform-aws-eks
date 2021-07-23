name = "eks-fis-tc2"
tags = {
  env  = "prod"
  test = "tc2"
}
aws_region         = "ap-northeast-1"
azs                = ["ap-northeast-1a", "ap-northeast-1d", "ap-northeast-1c"]
cidr               = "10.1.0.0/16"
kubernetes_version = "1.20"
