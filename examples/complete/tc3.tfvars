aws_region = "ap-northeast-2"
name       = "eks-tc3"
tags = {
  env  = "dev"
  test = "tc3"
}
kubernetes_version = "1.17"
node_groups = {
  default = {
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
    instances_distribution = {
      spot_allocation_strategy = "lowest-price"
      spot_max_price           = "0.03"
    }
    launch_override = [
      {
        instance_type     = "t3.small"
        weighted_capacity = 3
      },
      {
        instance_type     = "t3.medium"
        weighted_capacity = 2
      }
    ]
  }
}
