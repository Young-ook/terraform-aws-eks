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
kubernetes_version = "1.20"
node_groups = [
  {
    name          = "spot"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
    instances_distribution = {
      spot_allocation_strategy = "lowest-price"
      spot_max_price           = "0.036"
    }
  }
]
