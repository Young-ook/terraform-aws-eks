aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-cw-tc2"
tags = {
  env     = "dev"
  test    = "tc2"
  metrics = "false"
  logs    = "true"
}
kubernetes_version = "1.20"
enable_cw = {
  enable_metrics = false
  enable_logs    = true
}
