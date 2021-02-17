aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-spot-tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
kubernetes_version = "1.19"
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
