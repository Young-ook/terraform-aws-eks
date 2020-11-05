aws_region = "us-west-2"
azs        = ["us-west-2a", "us-west-2b", "us-west-2c"]
name       = "eks-arm64-tc1"
tags = {
  env  = "dev"
  arch = "arm64"
  test = "tc1"
}
kubernetes_version = "1.17"
node_groups = [
  {
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    arch          = "arm64"
    instance_type = "m6g.medium"
  }
]
