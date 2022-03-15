aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.1.0.0/16"
enable_igw = true
enable_ngw = true
single_ngw = true
name       = "eks-lbc"
tags = {
  env = "dev"
}
kubernetes_version  = "1.21"
managed_node_groups = []
node_groups         = []
fargate_profiles = [
  {
    name      = "default"
    namespace = "default"
  },
  {
    name      = "kube-system"
    namespace = "kube-system"
  },
]
