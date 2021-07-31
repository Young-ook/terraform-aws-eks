aws_region = "ap-northeast-1"
azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
cidr       = "10.1.0.0/16"
enable_igw = true
enable_ngw = true
single_ngw = true
name       = "eks-lbc-tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
kubernetes_version = "1.20"
node_groups = [
  {
    name          = "mixed"
    min_size      = 1
    max_size      = 3
    desired_size  = 3
    instance_type = "t3.medium"
    instances_distribution = {
      on_demand_percentage_above_base_capacity = 50
      spot_allocation_strategy                 = "capacity-optimized"
    }
    instances_override = [
      {
        instance_type     = "t3.small"
        weighted_capacity = 2
      },
      {
        instance_type     = "t3.large"
        weighted_capacity = 1
      }
    ]
  }
]
