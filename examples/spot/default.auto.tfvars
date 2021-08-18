aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "eks-spot"
tags = {
  env = "dev"
}
kubernetes_version  = "1.21"
managed_node_groups = []
node_groups = [
  {
    name          = "spot"
    desired_size  = 1
    instance_type = "t3.large"
    instances_distribution = {
      spot_allocation_strategy = "lowest-price"
      spot_max_price           = "0.036"
    }
  }
]
fargate_profiles = []
