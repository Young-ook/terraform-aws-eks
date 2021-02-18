aws_region = "us-west-2"
azs        = ["us-west-2a", "us-west-2b", "us-west-2c"]
name       = "eks-x86-arm64-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version = "1.19"
node_groups = [
  {
    name          = "arm64"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    arch          = "arm64"
    instance_type = "m6g.medium"
  },
  {
    name          = "x86"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.small"
  }
]
