aws_region = "us-west-2"
azs        = ["us-west-2a", "us-west-2b", "us-west-2c"]
name       = "eks-x86-arm64-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version  = "1.20"
managed_node_groups = []
node_groups = [
  {
    name          = "arm64"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "m6g.medium"
    ami_type      = "AL2_ARM_64"
  },
  {
    name          = "x86"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.small"
  }
]
