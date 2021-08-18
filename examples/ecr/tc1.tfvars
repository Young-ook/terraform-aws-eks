aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
cidr       = "10.0.0.0/16"
name       = "eks-ecr-tc1"
tags = {
  env      = "dev"
  platform = "fargate"
  test     = "tc1"
}
enable_igw          = true
enable_ngw          = true
single_ngw          = true
kubernetes_version  = "1.21"
managed_node_groups = []
node_groups         = []
fargate_profiles = [
  {
    name      = "hello"
    namespace = "hello"
  },
]
