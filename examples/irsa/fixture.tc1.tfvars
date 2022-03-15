name = "eks-irsa-tc1"
tags = {
  env       = "dev"
  test      = "tc1"
  nodegroup = "true"
}
aws_region         = "ap-northeast-1"
azs                = ["ap-northeast-1a", "ap-northeast-1d", "ap-northeast-1c"]
cidr               = "10.1.0.0/16"
enable_igw         = true
enable_ngw         = true
single_ngw         = true
kubernetes_version = "1.21"
managed_node_groups = [
  {
    name          = "default"
    desired_size  = 1
    instance_type = "t3.large"
  }
]
