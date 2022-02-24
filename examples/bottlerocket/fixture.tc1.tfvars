aws_region      = "ap-northeast-2"
use_default_vpc = false
name            = "eks-bottlerocket-tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
kubernetes_version = "1.21"
enable_ssm         = true
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.small"
    ami_type      = "AL2_x86_64"
  },
]
node_groups = [
  {
    name          = "default"
    instance_type = "t3.small"
  },
  {
    name          = "al2"
    instance_type = "t3.small"
    ami_type      = "AL2_x86_64"
  },
  {
    name          = "bottlerocket"
    instance_type = "t3.small"
    ami_type      = "BOTTLEROCKET_x86_64"
  },
  {
    name          = "al2-gpu"
    instance_type = "g4dn.xlarge"
    ami_type      = "AL2_x86_64_GPU"
  },
  {
    name          = "al2-arm"
    instance_type = "m6g.medium"
    ami_type      = "AL2_ARM_64"
  },
]
