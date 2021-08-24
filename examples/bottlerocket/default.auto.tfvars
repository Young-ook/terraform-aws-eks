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
    ami_type      = "BR_x86_64"
  },
]
