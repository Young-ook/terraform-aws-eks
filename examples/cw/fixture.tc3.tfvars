aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-cw-tc3"
tags = {
  env     = "dev"
  test    = "tc3"
  metrics = "true"
  logs    = "true"
}
kubernetes_version = "1.20"
enable_cw = {
  enable_metrics = true
  enable_logs    = true
}
