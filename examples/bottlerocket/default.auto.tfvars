aws_region = "ap-northeast-2"
name       = "eks-bottlerocket"
tags = {
  env = "dev"
}
kubernetes_version  = "1.21"
managed_node_groups = []
node_groups = [
  {
    name          = "bottlerocket"
    instance_type = "t3.small"
    ami_type      = "BOTTLEROCKET_x86_64"
  },
]


# allowed values for 'ami_type'
#  - AL2_x86_64
#  - AL2_x86_64_GPU
#  - AL2_ARM_64
#  - CUSTOM
#  - BOTTLEROCKET_ARM_64
#  - BOTTLEROCKET_x86_64
