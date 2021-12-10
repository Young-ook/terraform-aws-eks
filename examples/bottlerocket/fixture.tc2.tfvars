aws_region = "ap-northeast-2"
name       = "eks-bottlerocket-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version = "1.21"
enable_ssm         = true
managed_node_groups = [
  {
    name          = "bottlerocket-x86"
    instance_type = "t3.small"
    ami_type      = "BOTTLEROCKET_x86_64"
  },
  {
    name          = "bottlerocket-arm"
    instance_type = "m6g.medium"
    ami_type      = "BOTTLEROCKET_ARM_64"
  },
]
node_groups = [
  {
    name          = "bottlerocket-x86"
    instance_type = "t3.small"
    ami_type      = "BOTTLEROCKET_x86_64"
  },
  {
    name          = "bottlerocket-arm"
    instance_type = "m6g.medium"
    ami_type      = "BOTTLEROCKET_ARM_64"
  },
]
