aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
name       = "eks-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version = "1.17"
node_groups = {
  mixed = {
    min_size      = 1
    max_size      = 3
    desired_size  = 2
    instance_type = "t3.medium"
    instances_distribution = {
      on_demand_percentage_above_base_capacity = 50
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }
}
