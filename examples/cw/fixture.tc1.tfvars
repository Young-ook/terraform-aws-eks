aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-cw-tc1"
tags = {
  env     = "dev"
  test    = "tc1"
  metrics = "true"
  logs    = "false"
}
kubernetes_version = "1.20"
enable_cw = {
  enable_metrics = true
  enable_logs    = false
}
