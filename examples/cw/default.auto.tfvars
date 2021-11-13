aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
name       = "eks-cw"
tags = {
  env     = "dev"
  metrics = "false"
  logs    = "false"
}
kubernetes_version = "1.20"
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
  }
]
enable_cw = {
  enable_metrics = false
  enable_logs    = true
}
