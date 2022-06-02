aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
cidr       = "10.1.0.0/16"
enable_igw = true
enable_ngw = true
single_ngw = true
name       = "eks-lbc-tc2-fargate"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version  = "1.21"
managed_node_groups = []
node_groups         = []
fargate_profiles = [
  {
    name      = "game-2048"
    namespace = "game-2048"
  },
  {
    name      = "default"
    namespace = "default"
  },
  {
    name      = "kube-system"
    namespace = "kube-system"
  },
]
