aws_region = "ap-northeast-2"
name       = "eks-tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
kubernetes_version = "1.17"
node_groups = {
  default = {
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.medium"
    instances_distribution = {
      spot_allocation_strategy = "capacity-optimized"
    }
  }
}
